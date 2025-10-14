# 1) Parsing GPX — service d’import (extraits)

**Contexte**. À l’upload, on détecte ZIP/GPX, on matérialise les fichiers en local, on parse via GPXCacheParser, on mappe vers les référentiels (types, tailles, attributs), on enrichit l’altitude via OpenData, puis on insère en base (caches) et, si demandé, on upsert les trouvailles (found_caches).

```python
# Extrait&nbsp;: matérialiser le fichier, parser GPX, préparer les docs caches
gpx_paths = _materialize_to_paths(payload, filename)

items = []
for path in gpx_paths:
    parser = GPXCacheParser(gpx_file=path)
    items.extend(parser.parse())

# Mapping référentiels (types, tailles, attributs) + coords GeoJSON
type_id, size_id, attr_refs = _map_type_size_attrs(
    item.get("cache_type"), item.get("cache_size"), item.get("attributes"),
    all_types_by_name, all_sizes_by_name, all_attributes_by_id
)
loc = {"type":"Point", "coordinates":[lon, lat]} if lat is not None and lon is not None else None
```
```python
# Extrait&nbsp;: enrichissement altimétrique (APIs OpenData) + insertion en chunks
to_enrich_idx, points = [], []
for i, doc in enumerate(all_caches_to_db):
    if doc.get("lat") is not None and doc.get("lon") is not None and doc.get("elevation") is None:
        to_enrich_idx.append(i)
        points.append((float(doc["lat"]), float(doc["lon"])))

if points:
    elevations = await fetch_elevations(points)  # liste alignée
    for k, elev in enumerate(elevations):
        if elev is not None:
            all_caches_to_db[to_enrich_idx[k]]["elevation"] = int(elev)

# insert_many par paquets (gestion des duplicats via BulkWriteError)
```


# 2) Grammaire AST & exemple de tâches d’un UserChallenge

**Contexte**. Les règles des tâches sont modélisées en AST (Pydantic) avec des feuilles de sélection (type, taille, pays/état, D/T, attributs) et des agrégats (somme de D, T, D+T, altitude). Les noeuds logiques and/or/not permettent la composition.

```python
# Extrait (modèle)&nbsp;: quelques règles feuilles et le noeud logique AND
class RuleTypeIn(ASTBase):
    kind: Literal["type_in"] = "type_in"
    types: List[TypeSelector]

class RuleAttributes(ASTBase):
    kind: Literal["attributes"] = "attributes"
    attributes: List[AttributeSelector]

class RuleDifficultyBetween(ASTBase):
    kind: Literal["difficulty_between"] = "difficulty_between"
    min: float = Field(ge=1.0, le=5.0)
    max: float = Field(ge=1.0, le=5.0)

class TaskAnd(ASTBase):
    kind: Literal["and"] = "and"
    nodes: List[Union["TaskAnd", "TaskOr", "TaskNot", TaskLeaf]]
```

**Exemple (JSON) — deux tâches personnalisées pour un même challenge&nbsp;:**
```json
{
  "tasks": [
    {
      "title": "Série D/T équilibrée",
      "expression": {
        "kind": "and",
        "nodes": [
          { "kind": "difficulty_between", "min": 2.0, "max": 3.5 },
          { "kind": "terrain_between",    "min": 2.0, "max": 3.5 },
          { "kind": "type_in", "types": [ { "cache_type_code": "traditional" }, { "cache_type_code": "mystery" } ] }
        ]
      }
    },
    {
      "title": "Picnic en altitude",
      "expression": {
        "kind": "and",
        "nodes": [
          { "kind": "attributes", "attributes": [ { "code": "picnic", "is_positive": true } ] },
          { "kind": "aggregate_sum_altitude_at_least", "min_total": 5000 }
        ]
      }
    }
  ],
  "uc_logic": { "kind": "and", "task_ids": ["<id-task-1>", "<id-task-2>"] }
}
```

# Pytest - test d’import GPX (happy path + effets en base)

**Objectif**. Vérifier qu’un **upload GPX valide**&nbsp;:

- retourne **200 OK**
- **insère** des documents dans caches (et **optionnellement** dans found_caches si found=true)
- déclenche la **détection** des caches “challenge”

```python
# test_import_gpx.py

import io
import textwrap
from fastapi.testclient import TestClient
from app.main import app
from app.db.mongodb import db as mg_db

client = TestClient(app)

# GPX minimal viable (adapté à votre parser&nbsp;: namespaces, balises groundspeak/gsak)
SAMPLE_GPX = textwrap.dedent("""\
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.0"
     creator="cgeo"
     xmlns:gpx="http://www.topografix.com/GPX/1/0"
     xmlns:groundspeak="http://www.groundspeak.com/cache/1/0/1"
     xmlns:gsak="http://www.gsak.net/xmlv1/6">
  <gpx:wpt lat="43.2965" lon="5.3698">
    <gpx:name>GC12345</gpx:name>
    <gpx:desc>Une cache de test</gpx:desc>
    <groundspeak:cache>
      <groundspeak:type>Traditional Cache</groundspeak:type>
      <groundspeak:container>Small</groundspeak:container>
      <groundspeak:owner>OwnerX</groundspeak:owner>
      <groundspeak:difficulty>2.5</groundspeak:difficulty>
      <groundspeak:terrain>2.0</groundspeak:terrain>
      <groundspeak:country>France</groundspeak:country>
      <groundspeak:state>Bouches-du-Rhône</groundspeak:state>
      <groundspeak:long_description>Desc longue</groundspeak:long_description>
    </groundspeak:cache>
    <gpx:time>2024-01-10T00:00:00Z</gpx:time>
    <gsak:FavPoints>10</gsak:FavPoints>
  </gpx:wpt>
</gpx>
""").encode("utf-8")


def test_upload_gpx_inserts_caches(monkeypatch):
    # Cleanup ciblé (évite de toucher au reste de la base)
    mg_db.caches.delete_many({"GC": "GC12345"})
    mg_db.found_caches.delete_many({"cache_gc": "GC12345"})  # si vous stockez GC là, sinon adaptez

    files = {
        "file": ("sample.gpx", io.BytesIO(SAMPLE_GPX), "application/gpx+xml")
    }

    # found=false&nbsp;: on insère des caches, pas de found_caches
    resp = client.post("/caches/upload-gpx?found=false", files=files)
    assert resp.status_code == 200, resp.text

    # Vérifications DB (structure/clé à adapter à votre modèle)
    assert mg_db.caches.count_documents({"GC": "GC12345"}) == 1
    assert mg_db.found_caches.count_documents({"cache_gc": "GC12345"}) == 0


def test_upload_gpx_marks_found_when_flag_true(monkeypatch):
    mg_db.caches.delete_many({"GC": "GC12345"})
    mg_db.found_caches.delete_many({"cache_gc": "GC12345"})

    files = {
        "file": ("sample.gpx", io.BytesIO(SAMPLE_GPX), "application/gpx+xml")
    }

    # found=true&nbsp;: insère aussi une entrée dans found_caches (log de trouvaille)
    resp = client.post("/caches/upload-gpx?found=true", files=files)
    assert resp.status_code == 200, resp.text

    assert mg_db.caches.count_documents({"GC": "GC12345"}) == 1
    assert mg_db.found_caches.count_documents({"cache_gc": "GC12345"}) == 1
```

# AST → filtre MongoDB (avant / après)

**Objectif**. Illustrer comment une **expression AST** (tâche) est **compilée** en un **filtre MongoDB** prêt à exécuter.

### Exemple d’expression AST (JSON)

```json
{
  "kind": "and",
  "nodes": [
    { "kind": "type_in", "types": [ { "cache_type_code": "traditional" }, { "cache_type_code": "mystery" } ] },
    { "kind": "difficulty_between", "min": 2.0, "max": 3.5 },
    { "kind": "terrain_between",    "min": 2.0, "max": 3.5 },
    { "kind": "attributes", "attributes": [ { "code": "picnic", "is_positive": true }, { "code": "night", "is_positive": true } ] },
    { "kind": "country_in", "countries": [ "France" ] },
    { "kind": "state_in",   "states":    [ "Bouches-du-Rhône" ] }
  ]
}
```

```javascript
{
  "$and": [
    { "type_id": { "$in": [ 1, 8 ] }},                       // mapping codes → ids référentiel
    { "difficulty": { "$gte": 2.0, "$lte": 3.5 }},
    { "terrain":    { "$gte": 2.0, "$lte": 3.5 }},
    // tous les attributs positifs requis (elemMatch par attribut)
    { "attributes": { "$elemMatch": { "attribute_doc_id": 123, "is_positive": true }}},
    { "attributes": { "$elemMatch": { "attribute_doc_id": 456, "is_positive": true }}},
    { "country_id":  /* id(France) */  33 },
    { "state_id":    /* id(BdR)    */  13013 }
  ]
}
```

## Ajout d’une contrainte géo (rayon) au filtre

```javascript
{
  "$and": [
    /* ... filtre AST compilé ... */,
    {
      "loc": {
        "$geoWithin": {
          "$centerSphere": [ [ <lon>, <lat> ], <rayon_km> / 6378.1 ]
        }
      }
    }
  ]
}
```

