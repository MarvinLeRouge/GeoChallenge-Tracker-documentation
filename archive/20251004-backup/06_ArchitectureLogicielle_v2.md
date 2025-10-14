# 6. Architecture logicielle

## 6.1 Vue d’ensemble (Contexte)

Cette première vue présente le contexte global de l’application et les principales briques qui la composent.

* Application **web mobile-first** : frontend Vue communiquant avec une **API REST** FastAPI.
* Données persistées dans **MongoDB Atlas** (modèle documentaire).
* Intégrations externes : **OpenStreetMap** (tuiles), **APIs OpenData** (altimétrie, commune), **SMTP** (validation email).


\begin{figure}[H]
\centering
\includegraphics[width=\linewidth]{build-temp/assets/mermaid/06_ArchitectureLogicielle_v2-mmd-001.png}
\caption{Diagramme de contexte général}
\end{figure}


## 6.2 Vue conteneurs (environnements Dev/Prod)

L’architecture varie légèrement entre développement et production, mais repose toujours sur une séparation claire des services.

### 6.2.1 Dev (docker-compose)

* **frontend** : Vite (HMR) sur `5173/tcp`.
* **backend** : FastAPI/Uvicorn sur `8000/tcp`.
* **MongoDB** : Atlas (DB managée) — accès via variables d’environnement.

### 6.2.2 Prod

* **frontend** : build statique servi par **Nginx**.
* **backend** : Uvicorn derrière reverse proxy (Nginx/ingress selon hébergeur).
* **CI/CD** : GitHub Actions (tests → build images → déploiement).


\begin{figure}[H]
\centering
\includegraphics[width=\linewidth]{build-temp/assets/mermaid/06_ArchitectureLogicielle_v2-mmd-002.png}
\caption{Diagramme des conteneurs (déploiement dev/prod)}
\end{figure}


## 6.3 Composants backend (modules principaux)

Le backend est structuré en modules cohérents, correspondant aux routes, aux services métiers et aux composants techniques de base.

* **API / Routes**

  * `auth` : inscription, login, refresh, vérification email, renvoi code.
  * `caches` : upload GPX/ZIP, recherche par filtres, BBox / rayon, get par GC/ID.
  * `caches_elevation` : backfill altimétrie (admin).
  * `challenges` : (re)construction depuis caches *challenge* (admin).
  * `my-challenges` : lister/synchroniser/patcher mes *UserChallenges*.
  * `my-challenge-tasks` : lire/remplacer/valider les **tâches** d’un *UserChallenge*.
  * `my-challenge-progress` : lire/évaluer snapshots de progression.
  * `targets` : calculer/lister/effacer les **targets** (caches utiles).
  * `my_profile` : localisation utilisateur (get/put).
  * `maintenance` : endpoints réservés (diagnostic/maintenance).

* **Services**

  * `gpx_importer` : parsing GPX multi-namespaces, upsert caches, dédoublonnage.
  * `challenge_autocreate` : détection *challenge caches* → upsert `challenges`.
  * `user_challenges` : liste par utilisateur, sync `pending`.
  * `user_challenge_tasks` : validation/PUT complet des tâches (AST + contraintes).
  * `progress` : évaluation, snapshots, projections (courbes cumulées, estimations).
  * `targets` : agrégation caches satisfaisant ≥1 tâche, scoring, filtrage géo.
  * `elevation_retrieval` : backfill altimétrie (quotas, pagination, dry-run).
  * `providers` : adaptateurs vers APIs OpenData (altimétrie, reverse geocoding).
  * `referentials_cache` : référentiels (types, tailles, attributs, pays/états).
  * `query_builder` : construction de filtres Mongo à partir de règles/AST.

* **Core / Infra**

  * `core/settings` : configuration (env vars, secrets).
  * `core/security` : JWT + refresh, rôles `user`/`admin`, règles password, bcrypt.
  * `db/mongodb` : connexion, index, seeds.

<!-- pagebreak -->

## 6.4 Modèle logique des données (MongoDB)

Le modèle de données, implémenté dans MongoDB, est conçu pour représenter les entités principales du geocaching et leurs relations.
On peut par exemple ici observer la relation entre les entités **Caches** et **Cache_Attributes**, indiquant qu'une cache peut avoir 0 à n attributs, et qu'un cache_attribute donné peut exister dans 0 à n caches, ce type de relation se traduisant potentiellement par une table de jointure (si on souhaite conserver l'ensemble des couples).\
On y voit également la relation tripartite des entités Users - User_Challenges - Challenges. En effet, User_Challenges est basiquement l'association d'un User et d'un Challenge ; mais, dans a mesure où cette relation est porteuse de contenu propre (ici, un statut et des notes), elle sera nécessairement exprimée par une table de jointure.\
L'attribut **loc** de l'entité **caches** est ici d'un type abstrait **position** qui représente la notion de position géographique.

*Pour des questions d'ordre pratique, le schema ci-dessous est un extrait de la structure de la base de données, et non son intégralité.*


\begin{figure}[H]
\centering
\includegraphics[width=\linewidth]{build-temp/assets/mermaid/06_ArchitectureLogicielle_v2-mmd-003.png}
\end{figure}


<!-- pagebreak -->

## 6.5 Modèle physique des données (MongoDB)

On peut ici observer le MPD, qui est une concrétisation du MLD pour un moteur choisi de base de données.
Dans notre cas, on constate par exemple que les id sont sous forme de **uuid** (ce qui est le type réel sous-jacent des ObjectId MongoDB), que toutes les collections ont été dotées d'un champ **created_at** et d'un champ **updated_at** (*seuls certains sont représentés ici*), qu'on a uniquement conservé la relation **de caches vers cache_attributes** sous la forme d'un **array de uuid** car on n'utilise pas la réciproque d'un point de vue métier, ou qu'un type **GeoJSON** a été sélectionné pour **caches.loc**.


\begin{figure}[H]
\centering
\includegraphics[width=\linewidth]{build-temp/assets/mermaid/06_ArchitectureLogicielle_v2-mmd-004.png}
\caption{Modèle physique de données (MongoDB)}
\end{figure}


***Note***. L’index **2dsphere** sur le champ *caches.loc* est crucial ici : il permet à MongoDB d’exécuter efficacement des requêtes géospatiales (`$geoWithin`, `$nearSphere`) sur les coordonnées des caches, même à grande échelle. Sans cet index, les recherches par rayon (ex. “toutes les caches dans un périmètre de 25 km”) seraient un simple scan linéaire de la collection, donc inutilisable dès quelques milliers d’entrées.

<!-- pagebreak -->

## 6.6 Indexes créés (via seeding)

- **users**
  - `username` (unique, collation insensible à la casse)
  - `email` (unique, collation insensible à la casse)
  - `is_active`, `is_verified`
  - `location` (2dsphere)

- **countries**
  - `name` (unique)
  - `code` (unique, partial string)

- **states**
  - `(country_id, name)` (unique)
  - `(country_id, code)` (unique, partial string)
  - `country_id`

- **cache_attributes**
  - `cache_attribute_id` (unique)
  - `txt` (unique, partial string)
  - `name`

- **cache_sizes**
  - `name` (unique)
  - `code` (unique, partial string)

- **cache_types**
  - `name` (unique)
  - `code` (unique, partial string)

- **caches**
  - `GC` (unique)
  - `type_id`, `size_id`, `country_id`, `state_id`, `(country_id, state_id)`
  - `difficulty`, `terrain`, `placed_at`
  - `title + description_html` (index texte)
  - `loc` (2dsphere)
  - `(attributes.attribute_doc_id, attributes.is_positive)`
  - `(type_id, size_id)`
  - `(difficulty, terrain)`

- **found_caches**
  - `(user_id, cache_id)` (unique)
  - `(user_id, found_date)`
  - `cache_id`

- **challenges**
  - `cache_id` (unique)
  - `name + description` (index texte)

- **user_challenges**
  - `(user_id, challenge_id)` (unique)
  - `(user_id, status, updated_at)`
  - `user_id`, `challenge_id`, `status`

- **user_challenge_tasks**
  - `(user_challenge_id, order)`
  - `(user_challenge_id, status)`
  - `user_challenge_id`
  - `last_evaluated_at`

- **progress**
  - `(user_challenge_id, checked_at)` (unique)

- **targets**
  - `(user_challenge_id, cache_id)` (unique)
  - `(user_challenge_id, satisfies_task_ids)`
  - `(user_challenge_id, primary_task_id)`
  - `cache_id`
  - `(user_id, score)`
  - `(user_id, user_challenge_id, score)`
  - `loc` (2dsphere)
  - `(updated_at, created_at)`


## 6.7 Sécurité (vue architecture)

La sécurité a été intégrée dès la conception, tant côté backend que frontend, et couvre l’ensemble de la chaîne d’authentification.

* **Auth** : OAuth2 password flow (login) → **JWT** access + **refresh** (durées distinctes).
* **Rôles** : `user` / `admin` (endpoints d’admin protégés).
* **Comptes** : règles password strictes, **bcrypt + sel variable**, vérification email par lien **temporaire**.
* **Front** : stockage tokens (access en mémoire, refresh en stockage sécurisé si nécessaire), gardes de routes.
* **Back** : contrôle systématique `userId` côté serveur (aucune confiance dans le client), CORS configuré.
* **APIs externes** : clés en variables d’environnement ; timeouts, retries, backoff ; respect des quotas.

<!-- pagebreak -->

## 6.8 Modèle objet (diagramme de classe UML)

Le diagramme de classes ci-dessous propose une vision **objet/métier** de l’application.  
Il ne décrit pas le stockage des données (comme les MLD/MPD), mais la manière dont les **entités interagissent** dans le code et dans la logique métier.  

Chaque **classe** représente une entité principale (utilisateur, challenge, cache, tâche, etc.) avec ses **attributs clés**.  
Les **liens** indiquent les relations entre ces entités, en précisant leur **multiplicité** (par exemple : un utilisateur peut suivre plusieurs challenges).  


\begin{figure}[H]
\centering
\includegraphics[width=\linewidth]{build-temp/assets/mermaid/06_ArchitectureLogicielle_v2-mmd-005.png}
\caption{Modèle objet — Noyau métier}
\end{figure}


<!-- pagebreak -->


\begin{figure}[H]
\centering
\includegraphics[width=\linewidth]{build-temp/assets/mermaid/06_ArchitectureLogicielle_v2-mmd-006.png}
\caption{Modèle objet — Référentiels (catalogues)}
\end{figure}


Concrètement, ce diagramme se lit de la manière suivante :  
- Un **User** peut suivre plusieurs **UserChallenges**, chacun étant lié à un **Challenge**.  
- Chaque **UserChallenge** est composé de plusieurs **Tasks**, et possède une série de **Progress** ainsi qu’une liste de **Targets** calculés.  
- Les **Caches** sont décrits par leurs référentiels (type, taille, attributs, localisation).  
- Les **FoundCaches** enregistrent la relation entre un utilisateur et les caches qu’il a trouvées, avec la date correspondante.


<!-- pagebreak -->

## 6.9 Séquences clés (diagramme de séquence UML)

Les diagrammes suivants illustrent deux scénarios essentiels du fonctionnement de l’application.

### 6.9.1 Import GPX → sync challenges → premiers snapshots


\begin{figure}[H]
\centering
\includegraphics[width=\linewidth]{build-temp/assets/mermaid/06_ArchitectureLogicielle_v2-mmd-007.png}
\caption{Diagramme de séquence : import GPX et synchronisation}
\end{figure}


### 6.9.2 Consultation d’un challenge et projection


\begin{figure}[H]
\centering
\includegraphics[width=\linewidth]{build-temp/assets/mermaid/06_ArchitectureLogicielle_v2-mmd-008.png}
\caption{Diagramme de séquence : Consultation d’un challenge et projection}
\end{figure}


## 6.10 Performance & cache

Plusieurs mécanismes de performance et de mise en cache ont été intégrés pour assurer la fluidité de l’expérience utilisateur.

* **Clustering** des marqueurs sur carte, **tile caching** OSM côté front.
* **Caps** sur les calculs de targets (`limit_per_task`, `hard_limit_total`).
* **Pagination** standardisée (listes, nearby, bbox, radius ; page/limit ≤ 200).
* **Indices** adaptés (cf. 5.4) pour requêtes géo + filtres combinés.



## 6.11 Déploiement & configuration

L’architecture logicielle est complétée par une configuration claire des environnements et du pipeline de déploiement.

* **Docker** : images séparées frontend/backend ; compose pour dev.
* **Variables d’environnement** : DB (URI/credentials), secrets JWT, SMTP, fournisseurs OpenData.
* **CI/CD** : GitHub Actions — lint/tests → build → déploiement (Railway/équivalent).
* **Fichiers** : uploads GPX (répertoire dédié, nettoyage planifié recommandé).



## 6.12 Évolutions d’architecture envisagées

Enfin, certaines évolutions sont déjà identifiées pour enrichir l’architecture et anticiper les besoins futurs.

* **Mode offline** : IndexedDB + stratégie de sync.
* **Multi-challenges map** : vue combinée (optimisation multi-objectifs).
* **Cache applicatif** côté API (targets/progress récents).
* **Observabilité** : métriques Prometheus, traces OpenTelemetry.

