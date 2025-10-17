# 4. Spécifications fonctionnelles
## 4.1 Contraintes et livrables
### 4.1.1 Contraintes
**Contraintes temporelles**

- Deadline rendu dossier au 10/10/2025
- Définition d'une branche git stable à figer au 10/10/2025
- Recueil des retours testeurs et intégration au dossier avant la deadline

**Contraintes techniques**

- Utilisation d'APIs externes (OpenStreetMap, OpenTopoData)
- Respect des rate limits des services tiers
- Compatibilité avec les formats GPX standards

**Contraintes fonctionnelles**

- Support de 5 namespaces GPX différents
- Limitation du temps de parsing pour l'expérience utilisateur
- Contrôle des imports utilisateurs en taille pour l'expérience utilisateur (temps d'exécution, protection contre les crashes)

**Contraintes de sécurité**

- Authentification obligatoire
- Isolation des données par utilisateur
- Protection contre les injections

### 4.1.2 Livrables

- Dossier projet
- Projet sous la forme d'une branche github figée à date de rendu
- Version logicielle fonctionnelle

<!-- pagebreak -->
## 4.2 Architecture logicielle
### 4.2.1 Vue d'ensemble

Architecture **3-tiers moderne**

- **Présentation**&nbsp;: SPA Vue.js responsive
- **Métier**&nbsp;: API REST FastAPI
- **Données**&nbsp;: MongoDB Atlas


\begin{figure}[H]
\centering
\includegraphics[width=\linewidth]{build-temp/assets/mermaid/04-specificationsFonctionnelles-mmd-001.png}
\end{figure}


### 4.2.2 Composants backend

**Routes API**

- `/auth`&nbsp;: Authentification JWT
- `/caches`&nbsp;: CRUD et recherche
- `/my/challenges`&nbsp;: Gestion personnelle
- `/my/progress`&nbsp;: Suivi de progression
- `/my/targets`&nbsp;: Suggestions optimisées

**Services métier**

- `GPXParser`&nbsp;: Extraction multi-namespace
- `ChallengeService`&nbsp;: Gestion AST
- `ProgressService`&nbsp;: Calculs et projections
- `TargetService`&nbsp;: Algorithme de scoring

**Composants techniques**

- `Security`&nbsp;: JWT et permissions
- `Database`&nbsp;: Connexion MongoDB
- `Cache`&nbsp;: Référentiels en mémoire

### 4.2.3 Composants frontend

**Pages principales**

- `Home`&nbsp;: Landing et présentation
- `ImportGPX`&nbsp;: Upload et parsing
- `MyChallenges`&nbsp;: Liste et gestion
- `Progress`&nbsp;: Tableaux de bord

**Composants réutilisables**

- `MapBase`&nbsp;: Wrapper Leaflet
- `MarkerCluster`&nbsp;: Regroupement
- `FilterBar`&nbsp;: Critères de recherche
- `ProgressChart`&nbsp;: Graphiques

**Store Pinia**

- `authStore`&nbsp;: État authentification
- `cacheStore`&nbsp;: Données geocaching
- `challengeStore`&nbsp;: Challenges actifs

## 4.3 Charte graphique

Dans la conception de l'interface, une approche **mobile first** a été privilégiée. Ce choix repose sur plusieurs arguments. Tout d'abord, le mobile first conduit naturellement à une interface centrée sur le **contenu** et une **ergonomie simple et efficace**, ce qui correspond à l'objectif du projet. Cette orientation a été pensée en opposition à certains outils existants, comme *Project-GC*, dont le contenu est riche mais présenté de manière très dense&nbsp;: abondance de tableaux, polices réduites, couleurs juxtaposées dans de petites cases. Le résultat est puissant mais peu lisible sur mobile, et difficilement exploitable en situation de mobilité.  

Ensuite, l'application est amenée à être utilisée en **itinérance**, notamment pour la consultation cartographique lors de déplacements. Une ergonomie pensée pour le bureau (desktop) n'aurait donc pas été adaptée. Au contraire, l'interface mobile first assure une **utilisation fluide en contexte de terrain**, tout en restant **parfaitement utilisable sur desktop**. De plus, il est toujours plus aisé d'ajouter des **media queries** pour enrichir l'expérience sur grand écran que de tenter de linéariser une interface multi-colonnes afin de la rendre utilisable sur smartphone.  

Le design graphique repose volontairement sur une base **sobre et lisible**. Les polices choisies sont exclusivement **sans-serif**, le contraste entre texte et arrière-plan est maximal, et des nuances de gris ainsi que des variations de taille viennent hiérarchiser certains éléments. Ce travail permet une lecture confortable dans la majorité des situations. Une **passe d'accessibilité dédiée** pourra être envisagée dans une version ultérieure, afin de prendre en compte des besoins spécifiques (daltonisme, contrastes renforcés, lecteurs d'écran, etc.).  

La **navigation** a été conçue pour optimiser l'espace&nbsp;: des **menus dépliants** permettent de libérer la surface utile, tandis que des **icônes thématiques par section** facilitent le repérage et la mémorisation visuelle des fonctionnalités. Cet équilibre entre sobriété et guidage visuel constitue un gage d'ergonomie pour des utilisateurs variés, du joueur occasionnel au géocacheur expérimenté.  

Enfin, le **design épuré** retenu a aussi une incidence sur les performances. Il limite le nombre d'éléments graphiques et réduit donc les **temps de chargement**, la **bande passante consommée**, et même le **temps de mise en page (layout)** dans le navigateur. Cela correspond à une démarche naturellement plus efficiente sur le plan environnemental&nbsp;: un premier pas vers le **green IT**. Si la gestion efficace de la cartographie (notamment via le **tile caching**) constitue déjà un levier important, d'autres pistes d'optimisation (caching applicatif, traitement côté client mieux maîtrisé) pourront être explorées dans la suite du projet. Le design évite aussi toute lourdeur inutile&nbsp;: **aucune image lourde** n'est utilisée et les animations sont réduites au strict minimum.  

Le **nom** et le **logo** de l'application ont fait l'objet d'une réflexion spécifique. Le nom *GeoChallenge Tracker* exprime de manière explicite l'objectif du logiciel&nbsp;: aider l'utilisateur à suivre sa progression dans des challenges géocaching. Il se simplifie facilement en *GC Tracker*, une abréviation à la fois courte et parlante. L'acronyme *GC* résonne immédiatement auprès de la communauté, puisqu'il est déjà largement utilisé pour désigner *geocaching* ou *geocache*.  

Le logo reprend la base d'un **marqueur de position**, symbole universel de la géolocalisation, afin de rappeler immédiatement le contexte de l'activité. Plusieurs alternatives avaient été envisagées (escalier stylisé, coupe sportive, médaille, badge, ou encore dégradé de couleur), mais elles ont été écartées&nbsp;: trop complexes pour rester lisibles à petite taille, ou trop voyantes pour conserver une interface sobre. La solution finalement retenue repose sur un **histogramme intégré dans le marqueur**, exprimant à la fois la **notion de progression** et celle de **succès**. Les trois barres colorées montantes (rouge → jaune → vert) traduisent visuellement plusieurs idées&nbsp;: le **changement de statut** (échec → progression → réussite), l'**augmentation du taux de réalisation**, et la symbolique d'un **escalier**, associée à l'idée d'avancement et d'accomplissement. L'usage des couleurs s'appuie sur des codes universels, proches de ceux des feux de circulation ou des indicateurs sportifs, ce qui renforce l'immédiateté de la compréhension.  

Ainsi, l'ensemble des choix graphiques répond à un double objectif&nbsp;: proposer une **interface claire et efficace en mobilité**, tout en véhiculant une **identité visuelle forte** qui parle directement à la communauté geocaching.  

### 4.3.1 Page d'accueil

![Accueil+Menu non loggé](./screenshots/figma/homepage-menu-not-logged.png)

L'écran d'accueil, accessible sans connexion, sert avant tout de **teaser pour les géocacheurs**. 
Le haut de page met en avant la **simplicité du logiciel**, sa capacité à **remplacer avantageusement l'existant**, ainsi que son caractère **interactif** et l'intérêt de sa **cartographie**.
Le menu haut propose immédiatement les **actions essentielles**&nbsp;: créer un compte, se connecter, ou commencer.
Le contenu principal illustre les **étapes d'utilisation typiques**, avec une explication succincte de chaque phase.
Enfin, le **menu, volontairement réduit**, ne contient que les liens connexion / inscription, ainsi que les *mentions légales*, qui doivent rester *disponibles en toutes circonstances*.

### 4.3.2 Register / Login

![ Register / Login ](./screenshots/figma/register-login.png)

Les écrans d'inscription et de connexion suivent volontairement une **approche minimaliste**. Leur objectif est d'aller droit au but, conformément aux bonnes pratiques du domaine. 
Le formulaire d'inscription demande une confirmation du mot de passe, afin de **réduire les risques d'erreur** et d'**éviter la frustration** liée à un premier échec de connexion. 
La **sobriété visuelle** met en avant la **lisibilité** et la **fluidité** du parcours utilisateur.

### 4.3.3 Page d'accueil - Contenu complet

![ Accueil loggé - Contenu complet ](./screenshots/figma/homepage-logged-full-split.png)

La page d'accueil en version complète met en avant une **vision panoramique des fonctionnalités** disponibles. Le design conserve une structure claire, tout en affichant davantage d'éléments contextualisés pour l'utilisateur connecté. 
L'objectif est de fournir une **vue globale** qui associe lisibilité et exhaustivité, sans surcharger visuellement la page. Cette maquette met en lumière la **progression naturelle du parcours utilisateur**, depuis l'accès invité jusqu'à l'exploration complète des fonctionnalités. 

En conclusion, la conception graphique de GeoChallenge Tracker illustre une démarche pragmatique&nbsp;: partir des besoins des utilisateurs, proposer une interface simple et claire, et s'assurer que l'expérience reste fluide sur mobile comme sur desktop. L'usage de maquettes Figma a permis de matérialiser ces choix très tôt, en validant les parcours essentiels sans chercher à couvrir exhaustivement toutes les pages de l'application.  

Cette sobriété va de pair avec une réflexion sur les performances et l'impact environnemental. Dans une logique de **green IT**, toutes les ressources graphiques ont été optimisées, depuis les maquettes elles-mêmes jusqu'au logo en SVG, afin de réduire la taille des fichiers et d'accélérer leur affichage. L'ensemble contribue à un rendu plus léger et donc plus respectueux des contraintes de bande passante et de consommation.  

Ces choix traduisent une volonté de concilier **ergonomie, efficacité et responsabilité**, en offrant à la communauté des géocacheurs un outil accessible, lisible et durable, conçu dès l'origine avec une attention particulière portée à la simplicité et à la performance.

L'ensemble du prototype est consultable en ligne, [sur Figma](https://www.figma.com/proto/ba8qCI2QTFiJi3dkZAghaZ/Geocaching?node-id=0-1&t=09PPhu9lbqOrJfQR-1).

### 4.3.4 Enchaînement des écrans

\begin{figure}[H]
\centering
\includegraphics[width=\linewidth]{build-temp/assets/mermaid/04-specificationsFonctionnelles-mmd-002.png}
\end{figure}


## 4.4 Structures de données
### 4.4.1 Diagramme entités-associations


\begin{figure}[H]
\centering
\includegraphics[width=\linewidth]{build-temp/assets/mermaid/04-specificationsFonctionnelles-mmd-003.png}
\end{figure}


*Note*&nbsp;: MCD et MPD complets disponibles en annexe 2

### 4.4.2 Collections MongoDB

**users**
```javascript
{
  _id: ObjectId,
  username: String,
  email: String,
  password_hash: String,
  role: "user"|"admin",
  location: {
    latitude: Number,
    longitude: Number
  },
  created_at: Date,
  updated_at: Date
}
```

**caches**
```javascript
{
  _id: ObjectId,
  gc: String,           // GC12345
  name: String,
  loc: {
    type: "Point",
    coordinates: [lon, lat]
  },
  difficulty: Number,   // 1.0 - 5.0
  terrain: Number,      // 1.0 - 5.0
  type_id: ObjectId,    // ref cache_types
  size_id: ObjectId,    // ref cache_sizes
  attributes: [{
    attribute_doc_id: ObjectId,
    is_positive: Boolean
  }],
  owner: String,
  placed_at: Date,
  elevation: Number
}
```

<!--pagebreak -->
**user_challenges**
```javascript
{
  _id: ObjectId,
  user_id: ObjectId,
  challenge_id: ObjectId,
  status: "pending"|"accepted"|"dismissed"|"completed",
  computed_status: String,
  progress: Number,      // 0-100
  notes: String,
  started_at: Date,
  completed_at: Date
}
```

**user_challenge_tasks**
```javascript
{
  _id: ObjectId,
  user_challenge_id: ObjectId,
  title: String,
  expression: Object,    // AST
  status: "todo"|"in_progress"|"done",
  progress: Number,
  order: Number,
  constraints: {
    min_count: Number
  },
  metrics: {
    current_count: Number,
    target_count: Number
  }
}
```

**progress**
```javascript
{
  _id: ObjectId,
  user_challenge_id: ObjectId,
  checked_at: Date,
  overall_percent: Number,
  tasks: [{
    task_id: ObjectId,
    percent: Number,
    current_count: Number,
    aggregate: {
      total: Number,
      target: Number,
      unit: String
    }
  }],
  estimated_completion_at: Date
}
```

## 4.5 Script création base de données

Ce document décrit **comment initialiser** la base MongoDB (référentiels, compte admin) et **assurer la création des index** au démarrage, à partir des scripts fournis dans le backend.

### 4.5.1 Objectifs

L'initialisation de la base de données poursuit plusieurs objectifs essentiels, garantissant à la fois la robustesse et la sécurité de l'application.

* **Tester la connexion** à MongoDB et arrêter proprement en cas d'échec.
* **Créer/mettre à jour les index** (unicité, géo, texte, partiels, collation).
* **Seeder les référentiels** (types, tailles, attributs) et **l'utilisateur admin**.

### 4.5.2 Pré-requis & variables d'environnement

Avant d'exécuter les scripts, certains prérequis et variables doivent être définis pour assurer une configuration cohérente.

* **MongoDB Atlas** (ou compatible) accessible via URI.
* Variables d'environnement attendues&nbsp;:

  * `MONGODB_URI` (ou équivalent utilisé par l'app)
  * `ADMIN_USERNAME`, `ADMIN_EMAIL`, `ADMIN_PASSWORD`
  * (éventuellement) `SMTP_*` si la vérification email est testée

> **Sécurité**&nbsp;: ne versionnez jamais vos valeurs réelles. Utilisez un `.env` local ou des *repository secrets* côté CI/CD.

### 4.5.3 Données seedées

Les données de référence sont stockées dans des fichiers JSON et injectées lors du seeding initial.

Répertoires (backend)&nbsp;: `data/seeds/*.json`

* `cache_types.json`
* `cache_sizes.json`
* `cache_attributes.json`

> Les jeux de données sont insérés **si la collection est vide** (ou **forcés** avec l'option `--force`).

### 4.5.4 Index créés (via seeding)

Le script assure également la création des index nécessaires, de manière idempotente, afin de garantir les performances attendues.

* **users**&nbsp;: unicité insensible à la casse sur `username`, `email` (collation) ; index géo `location (2dsphere)` ; flags `is_active`, `is_verified`.
* **countries**&nbsp;: `name` (unique), `code` (unique partiel si string).
* **states**&nbsp;: `country_id` ; `(country_id, name)` unique ; `(country_id, code)` unique partiel.
* **cache\_attributes**&nbsp;: `cache_attribute_id` (unique), `txt` (unique partiel), `name`.
* **cache\_sizes**&nbsp;: `name` (unique), `code` (unique partiel).
* **cache\_types**&nbsp;: `name` (unique), `code` (unique partiel).
* **caches**&nbsp;: `GC` (unique), `loc (2dsphere)`, `type_id`, `size_id`, `country_id`, `state_id`, `(country_id, state_id)`, `difficulty`, `terrain`, `placed_at (desc)`,
  index **texte** `(title, description_html)`, et combinaisons métier&nbsp;: `(attributes.attribute_doc_id, attributes.is_positive)`, `(type_id, size_id)`, `(difficulty, terrain)`.
* **found\_caches**&nbsp;: `(user_id, cache_id)` (unique), `(user_id, found_date)`, `cache_id`.
* **challenges**&nbsp;: `cache_id` (unique), index **texte** `(name, description)`.
* **user\_challenges**&nbsp;: `(user_id, challenge_id)` (unique), `user_id`, `challenge_id`, `status`, `(user_id, status, updated_at)`.
* **user\_challenge\_tasks**&nbsp;: `(user_challenge_id, order)`, `(user_challenge_id, status)`, `user_challenge_id`, `last_evaluated_at`.
* **progress**&nbsp;: `(user_challenge_id, checked_at)` (unique).
* **targets**&nbsp;: `(user_challenge_id, cache_id)` (unique), `(user_challenge_id, satisfies_task_ids)`, `(user_challenge_id, primary_task_id)`, `cache_id`, `(user_id, score)`, `(user_id, user_challenge_id, score)`, `loc (2dsphere)`, `(updated_at, created_at)`.

L'index **2dsphere** est l'un des éléments centraux du modèle physique de la base. Chaque cache est représentée par un champ `loc` de type GeoJSON (`{ type: "Point", coordinates: [lon, lat] }`). Cet index permet à MongoDB d'exécuter de manière optimale toutes les requêtes géospatiales utilisées par l'application&nbsp;:

- sélection des caches dans un rayon donné (`$geoWithin` + `$centerSphere`),
- recherche des caches les plus proches d'un point (`$nearSphere`),
- filtrage combiné (géolocalisation + critères métiers D/T, attributs, type).

Grâce à l'index 2dsphere, ces requêtes s'exécutent en **temps logarithmique**, indépendamment de la taille totale de la collection, et restent performantes même après l'import massif de dizaines ou centaines de milliers de caches depuis des GPX. Il s'agit donc d'un **pré-requis technique essentiel** pour la fluidité de l'outil, qui doit être capable d'afficher en temps réel les caches pertinentes sur carte et de répondre aux tâches complexes des challenges sans ralentir l'expérience utilisateur.

### 4.5.5 Exécution (local, sans Docker)

Les scripts peuvent être exécutés aussi bien en local qu'au travers de Docker Compose, selon le contexte de développement.

Depuis la racine du backend :

```bash
# Activez votre venv au besoin puis&nbsp;:
python -m app.db.seed_data             # ping + ensure_indexes + seed référentiels + admin
python -m app.db.seed_data --force     # idem, mais vide les collections de référentiels avant réinsertion
```

> **Attention**&nbsp;: `--force` réinitialise les collections de référentiels (pas les données utilisateur).

### 4.5.6 Exécution (via Docker Compose)

```bash
# 1) Bâtir et lancer les conteneurs
docker compose up -d --build

# 2) Exécuter le seeding dans le conteneur backend
docker compose exec <backend> python -m app.db.seed_data --force
```

> Les secrets (URI Mongo, admin) doivent être injectés au conteneur via l'environnement (compose, variables Railway, etc.).

### 4.5.7 Composants clés (extraits commentés)

Les extraits suivants illustrent les mécanismes mis en place pour la gestion des index et le seeding des données.

**4.5.7.1 Assurer les index (idempotent)**

```python
# app/db/seed_indexes.py — extrait simplifié
from pymongo import ASCENDING, DESCENDING, TEXT
from pymongo.operations import IndexModel
from pymongo.collation import Collation
from app.db.mongodb import get_collection

COLLATION_CI = Collation(locale="en", strength=2)  # insensible à la casse

def ensure_index(coll_name, keys, *, name=None, unique=None, partial=None, collation=None):
    coll = get_collection(coll_name)
    # ... comparaison index existant / options ...
    opts = {}
    if name: opts['name'] = name
    if unique is not None: opts['unique'] = unique
    if partial: opts['partialFilterExpression'] = partial
    if collation is not None: opts['collation'] = collation
    coll.create_indexes([IndexModel(keys, **opts)])

# Exemple&nbsp;: unicité insensible à la casse
ensure_index('users', [('username', ASCENDING)], name='uniq_username_ci', unique=True, collation=COLLATION_CI)
```

<!-- pagebreak -->
**4.5.7.2 Seeding des référentiels & admin**

```python
# app/db/seed_data.py — extrait simplifié
from app.db.mongodb import db as mg_db, get_collection
from app.db.seed_indexes import ensure_indexes
from app.core import security

def seed_collection(file_path, collection_name, force=False):
    count = mg_db[collection_name].count_documents({})
    if count > 0 and not force:
        return
    if force:
        mg_db[collection_name].delete_many({})
    mg_db[collection_name].insert_many(json.load(open(file_path)))

def seed_admin_user():
    coll = get_collection("users")
    pwd_hash = security.pwd_context.hash(os.getenv("ADMIN_PASSWORD"))
    coll.update_one({"username": os.getenv("ADMIN_USERNAME")},
                    {"$set": {..., "password_hash": pwd_hash, "role": "admin"},
                     "$setOnInsert": {"created_at": now()}}, upsert=True)

if __name__ == "__main__":
    test_connection()   # ping Mongo
    ensure_indexes()    # création/MAJ idempotente des index
    seed_referentials(force="--force" in sys.argv)
```

### 4.5.8 Bonnes pratiques & sécurité

Quelques bonnes pratiques doivent être respectées pour maintenir la cohérence des données et la sécurité de l'application.

* **Idempotence**&nbsp;: relancer le script ne casse pas les index existants si la configuration n'a pas changé.
* **Collation**&nbsp;: utilisez des collations cohérentes pour les unicités *case-insensitive* (ex. utilisateurs).
* **Index géo & texte**&nbsp;: un seul index **texte** par collection ; vérifiez la présence des `2dsphere` pour les requêtes cartographiques.
* **Quotas & coûts**&nbsp;: la multiplication d'index a un **coût d'écriture** ; validez les index réellement utiles via vos workloads.
* **Secrets**&nbsp;: stockez l'URI Mongo et le mot de passe admin via variables d'environnement (jamais en clair).

### 4.5.9 Vérification après exécution

Une fois le seeding effectué, il est important de vérifier la présence effective des index attendus.
Checklist rapide (via mongosh) :

```javascript
use <your_db>
// Exemples
db.users.getIndexes()
db.caches.getIndexes()
db.challenges.getIndexes()
```

<!-- pagebreak -->
### 4.5.10 Tests associés au seeding

Des tests unitaires viennent compléter le dispositif afin de s'assurer de la bonne accessibilité de la base et du respect des contraintes.

Un test Pytest permet de vérifier que l'environnement backend accède bien à MongoDB :

```python
# backend/tests/test_connectivity.py
from app.db.mongodb import client as mg_client

def test_backend_can_access_mongo():
    dbs = mg_client.list_database_names()
    assert isinstance(dbs, list)
```

* Vérifie que la connexion fonctionne et qu'une liste de bases est renvoyée.
* Peut être lancé seul pour diagnostiquer un problème de connexion.
* Intégré dans la suite Pytest pour automatiser le contrôle lors du CI/CD.

## 4.6 Diagramme cas d'utilisations

\begin{figure}[H]
\centering
\includegraphics[width=\linewidth]{build-temp/assets/mermaid/04-specificationsFonctionnelles-mmd-004.png}
\caption{Diagramme de cas d'utilisation}
\end{figure}


<!-- pagebreak -->
## 4.7 Diagrammes de séquence
### 4.7.1 Authentification


\begin{figure}[H]
\centering
\includegraphics[width=\linewidth]{build-temp/assets/mermaid/04-specificationsFonctionnelles-mmd-005.png}
\end{figure}


### 4.7.2 Import GPX

\begin{figure}[H]
\centering
\includegraphics[width=\linewidth]{build-temp/assets/mermaid/04-specificationsFonctionnelles-mmd-006.png}
\end{figure}


### 4.7.3 Calcul de progression

\begin{figure}[H]
\centering
\includegraphics[width=\linewidth]{build-temp/assets/mermaid/04-specificationsFonctionnelles-mmd-007.png}
\end{figure}

