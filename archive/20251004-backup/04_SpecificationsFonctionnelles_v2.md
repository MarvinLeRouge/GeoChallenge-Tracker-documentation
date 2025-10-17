# 4. Spécifications fonctionnelles

## 4.1 Fonctionnalités principales

Les fonctionnalités principales de GeoChallenge Tracker couvrent l’ensemble du cycle d’utilisation, de l’authentification à la visualisation des projections de progression.

### 4.1.1 Authentification et sécurité

La sécurité est au cœur du projet, avec un système d’authentification robuste et des mécanismes de protection contre les attaques classiques.

* Inscription avec règles strictes de mot de passe (longueur, majuscules, minuscules, chiffres et caractères spéciaux).
* Stockage des mots de passe en **bcrypt** avec sel variable.
* Validation par email avec lien unique et limite temporelle de validité.
* Connexion sécurisée avec **JWT** et **refresh token** (durées distinctes).
* Gestion des rôles (`user`, `admin`) avec séparation stricte des droits.
* Prévention des injections : utilisation exclusive des méthodes sûres de MongoDB (`find_one`, `find_many`, `insert_many`, etc.).

### 4.1.2 Gestion des challenges

Les challenges constituent la brique centrale de l’application. Leur gestion suit un processus en plusieurs étapes, de la détection automatique à l’évaluation personnalisée.

* **Détection automatique** : lors de l’import GPX, les caches portant l’attribut *challenge* sont automatiquement repérées.
* **Référentiel de challenges (`challenges`)** : ces caches sont insérées/actualisées dans la collection `challenges` (identifiant GC, métadonnées minimales, liens, etc.).
* **Liste par utilisateur (`userChallenges`)** : chaque utilisateur dispose de sa propre liste dérivée du référentiel :

  * **acceptation / rejet** d’un challenge détecté ;
  * **personnalisation** : définition des **tâches** (conditions) par l’utilisateur via un éditeur basé sur une **grammaire AST** ; ces tâches peuvent **différer d’un utilisateur à l’autre** pour un même challenge ;
  * **notes** et méta associées au challenge.
* **Moteur d’évaluation** :

  * les **tâches définies par l’utilisateur** sont évaluées en **faisant correspondre** leurs conditions avec les **caractéristiques des caches** en base (trouvées ou non selon les logs) ;
  * calcul des **progress points** et de la progression globale à partir des tâches.
* **Traçabilité et mises à jour** : recalcul automatique après nouvel import ou modification des tâches.

*Note* : Chaque tâche est exprimée sous forme d’AST et compilée en requête Mongo.
**Exemple (JSON) — deux tâches personnalisées pour un même challenge :**
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

### 4.1.3 Import de caches

L’import des caches repose sur la lecture de fichiers GPX enrichis de plusieurs namespaces, garantissant compatibilité et exhaustivité.

* Support des fichiers GPX C\:Geo avec multi-namespaces :

  * `groundspeak` : [http://www.groundspeak.com/cache/1/0/1](http://www.groundspeak.com/cache/1/0/1)
  * `gsak` : [http://www.gsak.net/xmlv1/6](http://www.gsak.net/xmlv1/6)
  * `cgeo` : [http://www.cgeo.org/wptext/1/0](http://www.cgeo.org/wptext/1/0)
  * `topografix` : [http://www.topografix.com/GPX/1/0](http://www.topografix.com/GPX/1/0)

**Parsing GPX pur**. GPXCacheParser lit gpx/groundspeak/gsak, extrait les champs clés et normalise les attributs (id, is_positive, name).

```python
# Extrait : lecture des waypoints finaux et extraction des champs utiles
for wpt in tree.xpath("//gpx:wpt", namespaces=self.namespaces):
    cache_elem = wpt.find("groundspeak:cache", namespaces=self.namespaces)
    if cache_elem is None:
        continue

    cache = {
        "GC": self.find_text_deep(wpt, "gpx:name"),
        "title": self.find_text_deep(wpt, "gpx:desc"),
        "latitude": float(wpt.attrib["lat"]),
        "longitude": float(wpt.attrib["lon"]),
        "cache_type": self.find_text_deep(wpt, "groundspeak:type"),
        ...
        "description_html": self.sanitizer.clean_description_html(
            self.find_text_deep(wpt, "groundspeak:long_description")
        ),
        ...
        "placed_date": self.find_text_deep(wpt, "gpx:time"),
        "found_date": self.find_text_deep(wpt, "gsak:UserFound"),
        "attributes": self._parse_attributes(cache_elem),
    }
    self.caches.append(cache)
```


* Distinction entre caches connues et caches trouvées.
* Import incrémental, sans suppression automatique des caches déjà stockées.
* Détection et gestion des doublons.

### 4.1.4 Stockage des données

Toutes les données sont centralisées et structurées dans MongoDB, avec une séparation stricte entre utilisateurs.

* Stockage centralisé en MongoDB (caches, challenges, userChallenges, AST).
* Séparation stricte des données par utilisateur.
* Indexation et requêtes optimisées pour recherche rapide.

### 4.1.5 Cartographie

La cartographie permet de visualiser efficacement les caches et challenges, tout en restant performante sur mobile.

* Carte affichée par challenge.
* Filtrage par condition et distance.
* Recentrage manuel possible.
* Clustering automatique des marqueurs (*marker clustering*) pour zones à forte densité.
* Bibliothèque cartographique avec gestion du *tile caching* (OpenStreetMap).

### 4.1.6 Statistiques et projections

L’utilisateur dispose d’outils de suivi statistique avancés, permettant à la fois une vision d’ensemble et une estimation des échéances.

* Courbes cumulées de progression par tâche et par challenge.
* Stockage et datation de chaque **progress point**.
* Affichage simultané des courbes de chaque tâche et de la courbe globale.
* Estimation de la date de complétion (projection de tendance).
* Possibilité de filtrer l’affichage par courbe.

## 4.2 Évolutions futures

Plusieurs évolutions sont envisagées pour enrichir l’outil et anticiper les besoins futurs de la communauté.

* Affichage multi-challenges sur une même carte (optimisation des itinéraires et croisements de conditions).
* IndexedDB côté client pour un mode offline plus performant.
* Export GPX, CSV ou PDF des caches pertinentes.
* Authentification OAuth (Geocaching.com).
* IA d’assistance : proposition d’itinéraires optimisés selon zone, moyens de transport, réseau routier et progression.
* Optimisation des flux entre MongoDB et le client pour réduire la latence.
* Multilingue.

## 4.3 Contraintes techniques

Enfin, certaines contraintes techniques fixent les limites de l’application et orientent ses choix d’implémentation.

* Interface responsive, mobile-first.
* Performance mobile optimisée.
* Taille maximale de fichier GPX : 20 Mo (zip accepté pour optimisation transfert).
* Nombre maximum de challenges suivis par utilisateur : 200.
* Objectif d’accessibilité : WCAG 2.1 AA partiel.
* **Métriques de performance prévues** :

  * Import massif de **10 000 caches** en <30 sec.
  * Gestion fluide de **200 challenges actifs** par utilisateur.
  * Affichage cartographique interactif de **5 000 points** avec clustering en <2 sec.
