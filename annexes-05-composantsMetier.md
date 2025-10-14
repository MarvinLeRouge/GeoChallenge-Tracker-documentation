# 4. Composants métier

## 4.1 Parser GPX
```python
# backend/app/services/parsers/GPXCacheParser.py
# Parse un fichier GPX (ouvert depuis un chemin) pour extraire des géocaches structurées (métadonnées, attributs).

import html
from pathlib import Path
from typing import Any
from lxml import etree
from app.services.parsers.HTMLSanitizer import HTMLSanitizer

class GPXCacheParser:
    """Parseur GPX de géocaches.

    Description:
        Lit un fichier GPX (schémas `gpx`, `groundspeak`, `gsak`) et en extrait une
        liste de caches prêtes pour l'import : code GC, titre, coordonnées, type,
        taille, propriétaire, D/T, pays/état, description HTML (sanitisée), favoris,
        notes, dates (placement / found), attributs, etc.

    Attributes:
        gpx_file (Path): Chemin du fichier GPX.
        namespaces (dict): Préfixes d'espaces de noms XML utilisés pour les requêtes XPath.
        caches (list[dict]): Résultats accumulés après `parse()`.
        sanitizer (HTMLSanitizer): Sanitizeur HTML pour la description longue.
    """

    def __init__(self, gpx_file: Path):
        """Initialiser le parseur GPX.

        Description:
            Conserve le chemin vers le GPX, initialise les espaces de noms attendus
            et prépare les structures internes (liste `caches`, sanitizeur HTML).

        Args:
            gpx_file (Path): Chemin du fichier GPX à analyser.

        Returns:
            None
        """
        self.gpx_file = gpx_file
        self.namespaces = {
            "gpx": "http://www.topografix.com/GPX/1/0",
            "groundspeak": "http://www.groundspeak.com/cache/1/0/1",
            "gsak": "http://www.gsak.net/xmlv1/6",
        }
        self.caches: list[dict] = []
        self.sanitizer = HTMLSanitizer()

    def test(self):
        """Lister tous les tags XML (debug).

        Description:
            Parse le fichier et itère sur tous les éléments pour imprimer
            leurs `tag` (utilitaire de mise au point).

        Args:
            None

        Returns:
            None
        """
        tree = etree.parse(str(self.gpx_file))
        for elem in tree.getroot().iter():
            print(elem.tag)

    def parse(self) -> list[dict]:
        """Analyser le GPX et remplir `self.caches`.

        Description:
            - Parcourt les waypoints `//gpx:wpt` et cherche le sous-élément `groundspeak:cache`.\n
            - Pour chaque cache finale (`_is_final_waypoint`), extrait les champs utiles
              (GC, titre, coords, type, taille, owner, D/T, pays/état, description HTML
              nettoyée, favoris GSAK, notes, dates, attributs via `_parse_attributes`).\n
            - Empile chaque dict dans `self.caches`.

        Args:
            None

        Returns:
            list[dict]: Liste de caches structurées prêtes à l'import.
        """
        tree = etree.parse(str(self.gpx_file))
        nodes: Any = tree.xpath("//gpx:wpt", namespaces=self.namespaces)
        if not isinstance(nodes, list):
            raise ValueError("XPath did not return nodes")

        for wpt in nodes:
            cache_elem = wpt.find("groundspeak:cache", namespaces=self.namespaces)
            if cache_elem is None:
                continue

            is_final = self._is_final_waypoint(cache_elem)
            if is_final:
                cache = {
                    "GC": self.find_text_deep(wpt, "gpx:name"),
                    "title": self.find_text_deep(wpt, "gpx:desc"),
                    "latitude": float(wpt.attrib["lat"]),
                    "longitude": float(wpt.attrib["lon"]),
                    ...
                    "attributes": self._parse_attributes(cache_elem),
                }
                self.caches.append(cache)

        return self.caches

    def _parse_attributes(self, cache_elem) -> list[dict]:
        """Extraire la liste des attributs depuis `<groundspeak:attributes>`.

        Description:
            Parcourt les noeuds `groundspeak:attribute` et retourne des objets
            `{id: int, is_positive: bool, name: str}`.

        Args:
            cache_elem: Élément XML `<groundspeak:cache>` parent.

        Returns:
            list[dict]: Attributs normalisés (id / inc / libellé).
        """
        attrs = []
        for attr in cache_elem.xpath(
            "groundspeak:attributes/groundspeak:attribute", namespaces=self.namespaces
        ):
            attrs.append(
                {
                    "id": int(attr.get("id")),
                    "is_positive": attr.get("inc") == "1",
                    "name": attr.text.strip() if attr.text else "",
                }
            )

        return attrs

    def _has_corrected_coordinates(self, wpt_elem) -> bool:
        ...
    def _has_found_log(self, cache_elem) -> bool:
        ...
    def _was_found(self, wpt_elem) -> bool:
        ...
    def _is_final_waypoint(self, cache_elem) -> bool:
        ...
    def _text(self, element, default: str = "") -> str:
        ...
    def _html(self, element, default: str = "") -> str:
        ...
    def get_caches(self) -> list[dict]:
        ...
    def find_text_deep(self, element, tag: str) -> str:
        ...
```

## 4.2 Query builder
```python
# backend/app/services/query_builder.py
# Transforme une expression canonique (AND-only) en conditions MongoDB pour la collection `caches`.

from __future__ import annotations
from datetime import date, datetime
from typing import Any
from bson import ObjectId
from app.services.referentials_cache import (resolve_attribute_code, resolve_country_name, resolve_size_code, resolve_size_name, esolve_state_name, resolve_type_code)

# NOTE: on ne dépend pas des modèles Pydantic ici : on reçoit un dict "expression" déjà canonisé
# (cf. services/user_challenge_tasks.put_tasks qui stocke l'expression canonicalisée). :contentReference[oaicite:1]{index=1}


def _mk_date(dt_or_str: Any) -> datetime:
    ...

def _flatten_and_nodes(expr: dict[str, Any]) -> list[dict[str, Any]] | None:
    """Aplatir récursivement les noeuds `AND` en une liste de feuilles.

    Description:
        Retourne `None` si l'expression contient des `OR`/`NOT` (non supportés par le compilateur « AND-only »).

    Args:
        expr (dict): Expression AST canonique.

    Returns:
        list[dict] | None: Feuilles si AND pur, sinon None.
    """
    kind = expr.get("kind")
    if kind == "and":
        out: list[dict[str, Any]] = []
        for n in expr.get("nodes") or []:
            sub = _flatten_and_nodes(n) if isinstance(n, dict) else [n]
            if sub is None:
                return None
            out.extend(sub)
        return out
    if kind in ("or", "not"):
        return None
    return [expr]  # leaf


def _extract_aggregate_spec(
    leaves: list[dict[str, Any]]
) -> tuple[dict[str, Any] | None, list[dict[str, Any]]]:
    """Extraire la spécification d'agrégat et les feuilles « cache.* ».

    Description:
        Détecte la **première** feuille d'agrégat parmi:
        - `aggregate_sum_difficulty_at_least`
        - `aggregate_sum_terrain_at_least`
        - `aggregate_sum_diff_plus_terr_at_least`
        - `aggregate_sum_altitude_at_least`
        Retourne `(agg_spec, leaves_sans_agrégat)`.

    Args:
        leaves (list[dict]): Feuilles AND.

    Returns:
        tuple[dict | None, list[dict]]: Spéc d'agrégat (ou None) et feuilles restantes.
    """
    agg = None
    cache_leaves: list[dict[str, Any]] = []
    for lf in leaves:
        k = lf.get("kind")
        if k in (
            "aggregate_sum_difficulty_at_least",
            "aggregate_sum_terrain_at_least",
            "aggregate_sum_diff_plus_terr_at_least",
            "aggregate_sum_altitude_at_least",
        ):
            if agg is None and lf.get("min_total") is not None:
                mt = int(lf["min_total"])
                if k == "aggregate_sum_difficulty_at_least":
                    agg = {"kind": "difficulty", "min_total": mt}
                elif k == ...
        else:
            cache_leaves.append(lf)
    return agg, cache_leaves


def _compile_leaf_to_cache_pairs(leaf: dict[str, Any]) -> list[tuple[str, Any]]:
    """Compiler une feuille AST en `(champ, condition)` sur `caches`.

    Description:
        Supporte notamment:
        - `type_in`, `size_in` (résolution via référentiels/aliases)
        - `country_is`, `state_in`
        - `placed_year`, `placed_before`, `placed_after`
        - `difficulty_between`, `terrain_between`
        - `attributes` (±, `attributes.$elemMatch`)

    Args:
        leaf (dict): Feuille individuelle.

    Returns:
        list[tuple[str, Any]]: Paires `(champ, condition)` à fusionner en AND.
    """
    k = leaf.get("kind")
    out: list[tuple[str, Any]] = []

    oids: list[ObjectId] = []
    if k == "type_in":
        # 1) canonique: types: [{cache_type_doc_id | cache_type_id | cache_type_code}]
        for t in leaf.get("types") or []:
            oid = t.get("cache_type_doc_id")
            if not oid and t.get("cache_type_id") is not None:
                # numeric id non supporté nativement par le cache -> on ignore, ou ajoute si tu l'as dans cache
                pass
            if not oid and t.get("cache_type_code"):
                oid = resolve_type_code(t["cache_type_code"])
            if oid:
                oids.append(oid)

        if oids:
            out.append(("type_id", {"$in": list(dict.fromkeys(oids))}))
        return out

    # Traitement des cas size_in / country_is / state_in / placed_year / placed_before / placed_after / difficulty_between / terrain_between

    if k == "attributes":
        # Canonique: [{"cache_attribute_doc_id"| "cache_attribute_id" | "code", "is_positive": bool}]
        attrs = leaf.get("attributes") or []
        for a in attrs:
            is_pos = bool(a.get("is_positive", True))
            attr_oid = a.get("cache_attribute_doc_id") or a.get("attribute_doc_id")
            if not attr_oid and a.get("cache_attribute_id") is not None:
                # le cache retourne aussi l'id numérique via resolve_attribute_code(code) si tu veux;
                # ici on reste doc_id only
                pass
            if not attr_oid and a.get("code"):
                res = resolve_attribute_code(a["code"])
                attr_oid = res[0] if res else None

            if attr_oid:
                out.append(
                    (
                        "attributes",
                        {
                            "$elemMatch": {
                                "attribute_doc_id": ObjectId(str(attr_oid)),
                                "is_positive": is_pos,
                            }
                        },
                    )
                )
            else:
                out.append(("_id", ObjectId()))  # clause impossible

        return out

    return out


def compile_and_only(
    expr: dict[str, Any]
) -> tuple[str, dict[str, Any], bool, list[str], dict[str, Any] | None]:
    """Compiler une expression AND en filtres Mongo « caches.* ».

    Description:
        - Rejette `OR`/`NOT` (`supported=False`, notes).\n
        - Extrait un éventuel agrégat (diff/terr/diff+terr/altitude).\n
        - Compile chaque feuille en paires `(champ, condition)` et fusionne par champ (AND).\n
        - Génère une signature stable de l'expression (`"and:" + json.dumps(leaves)`).

    Args:
        expr (dict): Expression canonique.

    Returns:
        tuple:
            str: Signature compilée.
            dict: `match_caches` — conditions AND par champ.
            bool: `supported` — True si AND pur.
            list[str]: `notes` — avertissements/causes de non-support.
            dict | None: `aggregate_spec` — spécification d'agrégat.
    """
    leaves = _flatten_and_nodes(expr)
    if leaves is None:
        return ("unsupported:or-not", {}, False, ["or/not unsupported in MVP"], None)

    agg_spec, cache_leaves = _extract_aggregate_spec(leaves)
    parts: list[tuple[str, Any]] = []
    for lf in cache_leaves:
        parts.extend(_compile_leaf_to_cache_pairs(lf))

    # fusion (AND): grouper par champ; si plusieurs conds pour un même champ -> liste ET-ée
    match: dict[str, Any] = {}
    for field, cond in parts:
        if field in match:
            if not isinstance(match[field], list):
                match[field] = [match[field]]
            match[field].append(cond)
        else:
            match[field] = cond

    try:
        import json

        signature = "and:" + json.dumps({"leaves": cache_leaves}, default=str, sort_keys=True)
    except Exception:
        signature = "and:compiled"

    return (signature, match, True, [], agg_spec)
```

## 4.3 Calcul de snapshot progress
```python
# backend/app/services/progress.py
# Calcule des snapshots de progression par UserChallenge, mise à jour des statuts, et accès à l'historique.

from __future__ import annotations
import math
from datetime import date, datetime, timedelta
from typing import Any
from bson import ObjectId
from pymongo import ASCENDING, DESCENDING
from app.core.utils import now, utcnow
from app.db.mongodb import get_collection
from app.services.query_builder import compile_and_only

# ---------- Helpers ----------


def _ensure_uc_owned(user_id: ObjectId, uc_id: ObjectId) -> dict[str, Any]:
    """Vérifier que l'UC appartient bien à l'utilisateur.

    Description:
        Contrôle l'existence de `user_challenges[_id=uc_id, user_id=user_id]`. Lève en cas de non-appartenance.

    Args:
        user_id (ObjectId): Identifiant utilisateur.
        uc_id (ObjectId): Identifiant UserChallenge.

    Returns:
        dict: Document minimal (_id) si autorisé.

    Raises:
        PermissionError: Si l'UC n'appartient pas à l'utilisateur (ou n'existe pas).
    """
    ucs = get_collection("user_challenges")
    row = ucs.find_one({"_id": uc_id, "user_id": user_id}, {"_id": 1})
    if not row:
        raise PermissionError("UserChallenge not found or not owned by user")
    return row


def _get_tasks_for_uc(uc_id: ObjectId) -> list[dict[str, Any]]:
    ...
def _attr_id_by_cache_attr_id(cache_attribute_id: int) -> ObjectId | None:
    ...

def _count_found_caches_matching(user_id: ObjectId, match_caches: dict[str, Any]) -> int:
    """Compter les trouvailles d'un utilisateur qui matchent des conditions « caches.* ».

    Description:
        Pipeline: filtre par `user_id` sur `found_caches`, `$lookup` vers `caches`, `$unwind`,
        puis application des conditions (`match_caches`) sur `cache.*`, et `$count`.

    Args:
        user_id (ObjectId): Utilisateur concerné.
        match_caches (dict): Conditions AND sur des champs de `caches`.

    Returns:
        int: Nombre de trouvailles correspondantes.
    """
    fc = get_collection("found_caches")
    pipeline: list[dict[str, Any]] = [
        {"$match": {"user_id": user_id}},
        {
            "$lookup": {
                "from": "caches",
                "localField": "cache_id",
                "foreignField": "_id",
                "as": "cache",
            }
        },
        {"$unwind": "$cache"},
    ]

    # Apply match on cache.*
    conds: list[dict[str, Any]] = []
    for field, cond in match_caches.items():
        if isinstance(cond, list):
            # multiple conditions for the same field => all must hold
            for c in cond:
                conds.append({f"cache.{field}": c})
        else:
            conds.append({f"cache.{field}": cond})
    if conds:
        pipeline.append({"$match": {"$and": conds}})
    pipeline.append({"$count": "current_count"})
    rows = list(fc.aggregate(pipeline, allowDiskUse=False))
    return int(rows[0]["current_count"]) if rows else 0


def _aggregate_total(user_id: ObjectId, match_caches: dict[str, Any], spec: dict[str, Any]) -> int:
    """Calculer une somme agrégée (difficulté, terrain, diff+terr, altitude).

    Description:
        Filtre via `match_caches` puis somme la métrique demandée :
        - `difficulty` → somme des difficultés
        - `terrain` → somme des terrains
        - `diff_plus_terr` → somme (difficulté + terrain)
        - `altitude` → somme des altitudes

    Args:
        user_id (ObjectId): Utilisateur.
        match_caches (dict): Conditions AND sur `caches`.
        spec (dict): Spécification d'agrégat (`{'kind': ..., 'min_total': int}`).

    Returns:
        int: Total agrégé (0 si `kind` inconnu).
    """
    fc = get_collection("found_caches")
    pipeline: list[dict[str, Any]] = [
        {"$match": {"user_id": user_id}},
        {
            "$lookup": {
                "from": "caches",
                "localField": "cache_id",
                "foreignField": "_id",
                "as": "cache",
            }
        },
        {"$unwind": "$cache"},
    ]
    # Apply match on cache.*
    conds: list[dict[str, Any]] = []
    for field, cond in match_caches.items():
        if isinstance(cond, list):
            for c in cond:
                conds.append({f"cache.{field}": c})
        else:
            conds.append({f"cache.{field}": cond})
    if conds:
        pipeline.append({"$match": {"$and": conds}})

    k = spec["kind"]
    if k == "difficulty":
        score_expr = {"$ifNull": ["$cache.difficulty", 0]}
    elif k == "terrain":
        score_expr = {"$ifNull": ["$cache.terrain", 0]}
    elif k == "diff_plus_terr":
        score_expr = {
            "$add": [
                {"$ifNull": ["$cache.difficulty", 0]},
                {"$ifNull": ["$cache.terrain", 0]},
            ]
        }
    elif k == "altitude":
        score_expr = {"$ifNull": ["$cache.elevation", 0]}
    else:
        return 0

    pipeline += [
        {"$project": {"score": score_expr}},
        {"$group": {"_id": None, "total": {"$sum": "$score"}}},
    ]
    rows = list(fc.aggregate(pipeline, allowDiskUse=False))
    return int(rows[0]["total"]) if rows else 0


def _nth_found_date(user_id: ObjectId, match_caches: dict[str, Any], n: int) -> date | None:
    ...

def evaluate_progress(user_id: ObjectId, uc_id: ObjectId, force=False) -> dict[str, Any]:
    """Évaluer les tâches d'un UC et insérer un snapshot.

    Description:
        - Vérifie l'appartenance de l'UC (`_ensure_uc_owned`).\n
        - Si `force=False` et que l'UC est déjà `completed`, retourne le dernier snapshot (si existant).\n
        - Pour chaque tâche, compile l'expression (`compile_and_only`), compte les trouvailles, met à jour
          éventuellement le statut de la tâche, calcule les agrégats et le pourcentage.\n
        - Calcule l'agrégat global et crée un document `progress`. Si toutes les tâches supportées sont `done`,
          met à jour `user_challenges` en `completed` (statuts déclaré & calculé).

    Args:
        user_id (ObjectId): Utilisateur.
        uc_id (ObjectId): UserChallenge.
        force (bool): Forcer le recalcul même si UC complété.

    Returns:
        dict: Document snapshot inséré (avec `id` ajouté pour la réponse).
    """
    _ensure_uc_owned(user_id, uc_id)
    tasks = _get_tasks_for_uc(uc_id)
    snapshots: list[dict[str, Any]] = []
    sum_current = 0
    sum_min = 0
    tasks_supported = 0
    tasks_done = 0
    uc_statuses = get_collection("user_challenges").find_one(
        {"_id": uc_id}, {"status": 1, "computed_status": 1}
    )
    uc_status = (uc_statuses or {}).get("status")
    uc_computed_status = (uc_statuses or {}).get("computed_status")
    if (not force) and (uc_computed_status == "completed" or uc_status == "completed"):
        # Renvoyer le dernier snapshot existant, sans recalcul ni insertion
        last = get_collection("progress").find_one(
            {"user_challenge_id": uc_id}, sort=[("checked_at", -1), ("created_at", -1)]
        )
        if last:
            return last  # même shape que vos snapshots persistés
        # S'il n'y a pas encore de snapshot, on retombe sur le calcul normal

    for t in tasks:
        min_count = int((t.get("constraints") or {}).get("min_count") or 0)
        title = t.get("title") or "Task"
        order = int(t.get("order") or 0)
        status = (t.get("status") or "todo").lower()
        expr = t.get("expression") or {}

        if status == "done" and not force:
            snap = {
                "task_id": t["_id"],
                "order": order,
                "title": title,
                "status": status,
                "supported_for_progress": True,
                "compiled_signature": "override:done",
                "min_count": min_count,
                "current_count": min_count,
                "percent": 100.0,
                "notes": ["user override: done"],
                "evaluated_in_ms": 0,
                "last_evaluated_at": now(),
                "updated_at": t.get("updated_at"),
                "created_at": t.get("created_at"),
            }
        else:
            sig, match_caches, supported, notes, agg_spec = compile_and_only(expr)
            if not supported:
                snap = {
                    "task_id": t["_id"],
                    "order": order,
                    "title": title,
                    "supported_for_progress": False,
                    ...
                }
            else:
                tic = utcnow()
                current = _count_found_caches_matching(user_id, match_caches)
                ms = int((utcnow() - tic).total_seconds() * 1000)

                # base percent on min_count
                bounded = min(current, min_count) if min_count > 0 else current
                count_percent = (100.0 * (bounded / min_count)) if min_count > 0 else 100.0
                new_status = "done" if current >= min_count else status
                task_id = t["_id"]
                t["status"] = new_status
                if status != "done":
                    get_collection("user_challenge_tasks").update_one(
                        {"_id": task_id},
                        {
                            "$set": {
                                "status": new_status,
                                "last_evaluated_at": utcnow(),
                                "updated_at": utcnow(),
                            }
                        },
                    )

                # aggregate handling
                aggregate_total = None
                aggregate_target = None
                aggregate_percent = None
                aggregate_unit = None
                if agg_spec:
                    aggregate_total = _aggregate_total(user_id, match_caches, agg_spec)
                    aggregate_target = int(agg_spec.get("min_total", 0)) or None
                    if aggregate_target and aggregate_target > 0:
                        aggregate_percent = max(
                            0.0,
                            min(
                                100.0,
                                100.0 * (float(aggregate_total) / float(aggregate_target)),
                            ),
                        )
                    else:
                        aggregate_percent = None
                    # unit: altitude -> meters, otherwise points
                    aggregate_unit = "meters" if agg_spec.get("kind") == "altitude" else "points"

                # final percent rule (MVP):
                # - if both count & aggregate constraints exist -> percent = min(count_percent, aggregate_percent)
                # - if only count -> count_percent
                # - if only aggregate -> aggregate_percent or 0 if None
                if agg_spec and min_count > 0:
                    final_percent = min(count_percent, (aggregate_percent or 0.0))
                elif agg_spec and min_count == 0:
                    final_percent = aggregate_percent or 0.0
                else:
                    final_percent = count_percent

                # --- dates de progression persistées sur la task ---
                task_id = t["_id"]
                min_count = int((t.get("constraints") or {}).get("min_count") or 0)

                # 2.1 start_found_at : première trouvaille qui matche
                start_dt = _first_found_date(user_id, match_caches)
                if start_dt and not t.get("start_found_at"):
                    get_collection("user_challenge_tasks").update_one(
                        {"_id": task_id},
                        {"$set": {"start_found_at": start_dt, "updated_at": utcnow()}},
                    )
                    t["start_found_at"] = start_dt  # en mémoire pour la suite

                # 2.2 completed_at : date de la min_count-ième trouvaille
                completed_dt = None
                if min_count > 0 and current >= min_count:
                    completed_dt = _nth_found_date(user_id, match_caches, min_count)

                # persister la date si atteinte, sinon l'annuler si elle existait mais plus valide
                if completed_dt:
                    if t.get("completed_at") != completed_dt:
                        get_collection("user_challenge_tasks").update_one(
                            {"_id": task_id},
                            {
                                "$set": {
                                    "completed_at": completed_dt,
                                    "updated_at": utcnow(),
                                }
                            },
                        )
                        t["completed_at"] = completed_dt
                else:
                    if t.get("completed_at") is not None:
                        get_collection("user_challenge_tasks").update_one(
                            {"_id": task_id},
                            {"$set": {"completed_at": None, "updated_at": utcnow()}},
                        )
                        t["completed_at"] = None

                snap = {
                    "task_id": t["_id"],
                    "order": order,
                    "title": title,
                    "status": t["status"],
                    "supported_for_progress": True,
                    "compiled_signature": sig,
                    "min_count": min_count,
                    "current_count": current,
                    "percent": final_percent,
                    # per-task aggregate block for DTO:
                    "aggregate": (
                        None
                        if not agg_spec
                        else {
                            "total": aggregate_total,
                            "target": aggregate_target or 0,
                            "unit": aggregate_unit or "points",
                        }
                    ),
                    "notes": notes,
                    "evaluated_in_ms": ms,
                    "last_evaluated_at": now(),
                    "updated_at": t.get("updated_at"),
                    "created_at": t.get("created_at"),
                }

        if snap["supported_for_progress"]:
            tasks_supported += 1
            sum_min += max(0, min_count)
            bounded_for_sum = (
                min(snap["current_count"], min_count) if min_count > 0 else snap["current_count"]
            )
            sum_current += bounded_for_sum
            if bounded_for_sum >= min_count and min_count > 0:
                tasks_done += 1

        snapshots.append(snap)

    aggregate_percent = (100.0 * (sum_current / sum_min)) if sum_min > 0 else 0.0
    aggregate_percent = round(aggregate_percent, 1)
    doc = {
        "user_challenge_id": uc_id,
        "checked_at": now(),
        "aggregate": {
            "percent": aggregate_percent,
            "tasks_done": tasks_done,
            "tasks_total": tasks_supported,
            "checked_at": now(),
        },
        "tasks": snapshots,
        "message": None,
        "created_at": now(),
    }
    if (uc_computed_status != "completed") and (tasks_done == tasks_supported):
        new_status = "completed"
        get_collection("user_challenges").update_one(
            {"_id": uc_id},
            {
                "$set": {
                    "computed_status": new_status,
                    "status": new_status,
                    "updated_at": utcnow(),
                }
            },
        )
    get_collection("progress").insert_one(doc)
    # enrich for response
    doc["id"] = str(doc.get("_id")) if "_id" in doc else None

    return doc


def get_latest_and_history(
    user_id: ObjectId,
    uc_id: ObjectId,
    limit: int = 10,
    before: datetime | None = None,
) -> dict[str, Any]:
    """Obtenir le dernier snapshot et un historique court.

    Description:
        Récupère jusqu'à `limit` snapshots (tri desc), renvoie le plus récent et un historique
        résumé (date + agrégat). `before` permet de paginer en arrière.

    Args:
        user_id (ObjectId): Utilisateur.
        uc_id (ObjectId): UserChallenge.
        limit (int): Taille max de l'historique (≥1).
        before (datetime | None): Curseur temporel exclusif.

    Returns:
        dict: `{'latest': dict | None, 'history': list[dict]}`.
    """
    q: dict[str, Any] = {}
    _ensure_uc_owned(user_id, uc_id)
    coll = get_collection("progress")
    q = {"user_challenge_id": uc_id}
    if before:
        q["checked_at"] = {"$lt": before}
    cur = coll.find(q).sort([("checked_at", DESCENDING)]).limit(limit)
    items = list(cur)
    latest = items[0] if items else None
    history = items[1:] if len(items) > 1 else []

    # --- enrichir 'latest' avec ETA par tâche + ETA globale ---
    if latest:
        # map (task_id -> {start_found_at, completed_at, min_count courant})
        tasks_coll = get_collection("user_challenge_tasks")
        tdocs = list(
            tasks_coll.find(
                {"user_challenge_id": uc_id},
                {"_id": 1, "start_found_at": 1, "completed_at": 1, "constraints": 1},
            )
        )
        dates_by_tid: dict[ObjectId, dict[str, Any]] = {
            d["_id"]: {
                "start": d.get("start_found_at"),
                "done": d.get("completed_at"),
                "min_count": int((d.get("constraints") or {}).get("min_count") or 0),
            }
            for d in tdocs
        }

        # calcule ETA par tâche du snapshot 'latest' en fonction d'aujourd'hui
        now_dt = now()
        eta_values: list[datetime] = []
        for it in latest.get("tasks") or []:
            tid = it.get("task_id")
            cur = int(it.get("current_count") or 0)
            # min_count : priorité au snapshot si présent, sinon doc task
            min_c = int(it.get("min_count") or dates_by_tid.get(tid, {}).get("min_count") or 0)
            info = dates_by_tid.get(tid) or {}
            start = info.get("start")
            done = info.get("done")

            eta = None
            if done:
                # terminé -> ETA figée
                # found_date est un 'date', on le normalise en 'datetime' pour la réponse
                eta = datetime(done.year, done.month, done.day)  # 00:00 locale/UTC selon now()
            elif start and cur >= 1 and min_c > 0:
                # progression -> extrapolation
                # vitesse = (cur - 1) / jours écoulés depuis la 1ère trouvaille
                elapsed_days = max((now_dt.date() - start.date()).days, 1)
                speed = float(cur - 1) / float(elapsed_days)
                remaining = max(0, min_c - cur)
                if speed > 0.0 and remaining > 0:
                    eta_days = int(math.ceil(remaining / speed))
                    eta_date = now_dt.date() + timedelta(days=eta_days)
                    eta = datetime(eta_date.year, eta_date.month, eta_date.day)
                # sinon, eta = None

            # injecter l'ETA par tâche dans l'objet 'latest' (pour DTO)
            it["estimated_completion_at"] = eta

            if eta:
                eta_values.append(eta)

        # ETA globale = max des ETA non-None
        latest.setdefault("aggregate", {})
        latest["estimated_completion_at"] = max(eta_values) if eta_values else None

    def _summarize(d: dict[str, Any]) -> dict[str, Any]:
        return {
            "checked_at": d["checked_at"],
            "aggregate": d["aggregate"],
        }

    res = {
        "latest": latest,
        "history": [_summarize(h) for h in history],
    }
    if latest and "_id" in latest:
        latest["id"] = str(latest["_id"])
    return res


def evaluate_new_progress(
    user_id: ObjectId,
    *,
    include_pending: bool = False,
    limit: int = 50,
    since: datetime | None = None,
) -> dict[str, Any]:
    """Évaluer un premier snapshot pour les UC sans progression.

    Description:
        Sélectionne les UC de l'utilisateur avec statut `accepted` (et `pending` si demandé),
        optionnellement créés depuis `since`, **ignore** ceux ayant déjà du `progress`,
        puis évalue jusqu'à `limit` items.

    Args:
        user_id (ObjectId): Utilisateur.
        include_pending (bool): Inclure les UC `pending`.
        limit (int): Nombre max d'UC à traiter.
        since (datetime | None): Filtre de date de création.

    Returns:
        dict: `{'evaluated_count': int, 'skipped_count': int, 'uc_ids': list[str]}`.
    """
    ucs = get_collection("user_challenges")
    progress = get_collection("progress")

    st = ["accepted"] + (["pending"] if include_pending else [])
    q: dict[str, Any] = {"user_id": user_id, "status": {"$in": st}}
    if since:
        q["created_at"] = {"$gte": since}

    # candidates
    cand = list(ucs.find(q, {"_id": 1}).sort([("_id", ASCENDING)]).limit(limit * 3))
    uc_ids = [c["_id"] for c in cand]

    # remove those already in progress
    if not uc_ids:
        return {"evaluated_count": 0, "skipped_count": 0, "uc_ids": []}
    present = set(
        d["user_challenge_id"]
        for d in progress.find({"user_challenge_id": {"$in": uc_ids}}, {"user_challenge_id": 1})
    )
    todo = [uc_id for uc_id in uc_ids if uc_id not in present][:limit]

    evaluated_ids: list[str] = []
    for uc_id in todo:
        evaluate_progress(user_id, uc_id)
        evaluated_ids.append(str(uc_id))

    return {
        "evaluated_count": len(evaluated_ids),
        "skipped_count": len(uc_ids) - len(evaluated_ids),
        "uc_ids": evaluated_ids,
    }
```