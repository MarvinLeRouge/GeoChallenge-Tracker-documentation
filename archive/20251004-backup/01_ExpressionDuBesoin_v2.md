# 1. Expression du besoin

## 1.1 Contexte

Le geocaching est un loisir mondial qui consiste à rechercher des caches dissimulées dans divers environnements, allant des zones urbaines aux milieux naturels les plus reculés. Certaines caches, appelées *challenges*, nécessitent non seulement d’être trouvées physiquement, mais aussi que certaines conditions soient remplies (nombre de caches trouvées, dates précises, attributs spécifiques, etc.).

## 1.2 Problématique

Le suivi des challenges ne se limite pas à une simple statistique ponctuelle : il devient une véritable gestion de projet personnelle. C’est précisément à ce stade que la problématique apparaît.

Les conditions à remplir sont souvent réparties dans le temps, difficiles à suivre mentalement, et nécessitent un outil de gestion précis. Aujourd’hui, de nombreux utilisateurs s’en remettent à des feuilles de calcul ou à des systèmes peu ergonomiques.

## 1.3 Analyse de l’existant

Pour comprendre l’intérêt d’un nouvel outil, il est nécessaire d’examiner les solutions déjà disponibles dans l'écosystème.

La seule alternative notable identifiée est **Project-GC**, plateforme externe proposant de nombreuses statistiques, dont une section dédiée aux challenges.

### 1.3.1 Fonctionnalités proposées par Project-GC
- **Statistiques exhaustives** : nombre de challenges trouvés, distribution par date, par D/T (difficulté/terrain), par difficulté calculée.
- **Tableaux et heatmaps** : visualisation de la couverture D/T et des périodes de complétion.
- **Détail des challenges trouvés** : liste par cache (GC code, nom, D/T, date).
- **Gamification** : badges, médailles, classements visibles.

![Challenges dashboard](./screenshots/project-gc/challenges-dashboard.png){ height=90% }

<!-- pagebreak -->

![Avancée des challenges](./screenshots/project-gc/challenges-dt.png){ width=75% }

![Listes](./screenshots/project-gc/challenges-liste2.png){ width=75% }

<!-- pagebreak -->

### 1.3.2 Limites de Project-GC
- **Interface dense** : de nombreux tableaux et graphiques, peu lisibles sur mobile.
- **Personnalisation limitée** : les conditions de challenge sont imposées par la plateforme, sans possibilité pour l’utilisateur de les adapter ou d’interpréter différemment.
- **Absence de projection** : pas d’outils pour estimer la progression ou prévoir une date de complétion.
- **Accès restreint** : les fonctionnalités challenges nécessitent un abonnement premium.

### 1.3.3 Valeur ajoutée de GeoChallenge Tracker
- **Personnalisation** : chaque utilisateur définit ses propres tâches (via une grammaire AST), permettant différentes interprétations d’un même challenge.
- **Projections temporelles** : graphiques de progression avec estimation de date de complétion.
- **Ergonomie mobile-first** : affichage sous forme de cartes (OSM, clustering), filtrage simple, utilisation fluide en mobilité.
- **Gratuité et indépendance** : pas d’abonnement premium requis, basé sur APIs ouvertes et contributions de la communauté.


Avec cette analyse, il apparaît clairement que Project-GC fournit une base intéressante, mais limitée.  
**GeoChallenge Tracker** se positionne comme un outil complémentaire, gratuit et personnalisable, répondant directement aux besoins exprimés par les géocacheurs.

## 1.4 Objectifs

Le projet **GeoChallenge Tracker** vise à fournir une application web mobile-first, conviviale et sécurisée. À partir de cette problématique et de l’analyse de l’existant, les fonctionnalités principales du projet peuvent être clairement formulées :

* importer ses listes de caches connues ou trouvées (GPX),
* détecter automatiquement les challenges présents dans les données importées,
* gérer ses challenges et de les exprimer sous forme d’un ensemble de tâches liées à des caches à trouver,
* consulter la progression détaillée par tâche et par challenge,
* visualiser une projection dans le temps de l’avancement vers la complétion,
* identifier les caches restantes permettant de progresser sur ses objectifs.

L’outil doit rendre lisible la progression statistique et projeter, à l’aide de tendances, une date estimée de complétion pour chaque challenge.

## 1.5 Périmètre fonctionnel et hors-périmètre

La phase initiale de développement étant limitée dans le temps, un périmètre fonctionnel initial suffisant a été défini, tout en anticipant des évolutions futures.

**Inclus en V1 :**

* Challenges : nombre de caches, D/T, type de caches.
* Import GPX C\:Geo avec namespaces supportés : groundspeak, gsak, cgeo, topografix.
* Cartographie via OpenStreetMap avec *tile caching* et *marker clustering* pour gérer les zones à forte densité.
* Version mobile optimisée (le desktop reprend le même rendu).

**Prévu en évolution :**

* Export GPX des caches utiles.
* Types de challenges supplémentaires.
* Authentification OAuth.
* Multilingue.
* IA de détection : proposer des journées de géocaching optimisées en fonction de la zone, du moyen de transport et du réseau routier, pour maximiser la progression sur les challenges sélectionnés.

## 1.6 Sources de données et intégrations

La richesse fonctionnelle de l’application repose sur des données fiables et variées. Voici les sources exploitées et la manière dont elles sont intégrées.

* Fichiers GPX format C\:Geo utilisant les namespaces :

  * `groundspeak` : [http://www.groundspeak.com/cache/1/0/1](http://www.groundspeak.com/cache/1/0/1)
  * `gsak` : [http://www.gsak.net/xmlv1/6](http://www.gsak.net/xmlv1/6)
  * `cgeo` : [http://www.cgeo.org/wptext/1/0](http://www.cgeo.org/wptext/1/0)
  * `topografix` : [http://www.topografix.com/GPX/1/0](http://www.topografix.com/GPX/1/0)
* Cartographie OpenStreetMap avec cache des tuiles et *marker clustering*.
* Modèle minimal : identifiant, coordonnées, type, D/T, attributs, dates de logs.
* Mise à jour incrémentale, pas de suppression/modification initialement.

## 1.7 Utilisateurs et rôles

L’application distingue deux types d’utilisateurs, correspondant à des rôles bien définis.

* **Utilisateur** : gère ses challenges, import GPX, visualisation progression.
* **Admin** : mêmes droits + futures prérogatives de modification/suppression.

## 1.8 Parcours utilisateur clés

Les parcours clés identifiés sont les suivants :

1. Inscription / validation email.
2. Import de fichiers GPX de caches et de caches trouvées.
3. Détection automatique des challenges à partir des données importées.
4. Acceptation ou rejet des challenges détectés.
5. Décomposition des challenges acceptés en tâches via une grammaire AST.
6. Consultation de la progression et proposition de caches utiles.

## 1.9 Indicateurs de succès (KPI)

Pour mesurer l’impact du projet, des indicateurs de succès ont été définis dès le départ.

* Nombre d’utilisateurs test.
* Taux d’import réussi.
* Nombre moyen de challenges suivis.
* Panel testeurs expérimentés (>20 000 caches).

## 1.10 Exigences non fonctionnelles

Au-delà des fonctionnalités visibles, certaines exigences techniques et qualitatives doivent être respectées pour assurer robustesse et pérennité.

Les exigences non fonctionnelles couvrent les aspects techniques, qualité et performance du système :

* **Sécurité** : authentification sécurisée, chiffrement des mots de passe, prévention des injections.
* **Confidentialité** : stockage des données utilisateur dans une base MongoDB distante sécurisée.
* **RGPD** : conformité à la législation française à la sortie publique.
* **Performance** : taille maximale de fichier GPX fixée à 20 Mo, upload possible en ZIP.
* **Compatibilité** : support des navigateurs modernes.
* **Accessibilité** : objectif WCAG 2.1 AA partiel.
* **Internationalisation** : français uniquement en V1.

## 1.11 Contraintes et dépendances

Le projet doit aussi composer avec un ensemble de contraintes techniques et organisationnelles, ainsi que des risques identifiés.

* Échéance : 19/09/2025.
* API de reverse geocoding (à définir).
* Hébergement Railway en développement.

## 1.12 Contraintes et risques

**Contraintes principales :**

* **Échéance** : 19/09/2025.
* **Cartographie** : respect des licences OpenStreetMap et gestion optimisée des appels (tile caching).
* **Hébergement** : environnement Railway en développement, avec MongoDB Atlas pour la base distante.
* **Performance** : taille maximale de fichier GPX fixée à 20 Mo, upload possible en ZIP.
* **Compatibilité** : support des navigateurs modernes, responsive et mobile-first.
* **Accessibilité** : objectif WCAG 2.1 AA partiel.
* **Internationalisation** : français uniquement en V1.

**Risques identifiés et mesures de mitigation :**

* **Volumétrie élevée** : limitation de la taille des GPX importés par appel, optimisation des parsings et de l’indexation MongoDB.
* **Changement de format GPX** : adaptation du module de parsing grâce à une architecture flexible et basée sur une grammaire AST.
* **Données d’altimétrie et localisation** :

  * **Risque** : dépendance à des APIs opendata externes (changement de format, indisponibilité, quotas).
  * **Mitigation** :

    * recours à des APIs publiques et non contractuelles → possibilité de changer de fournisseur ou d’en combiner plusieurs ;
    * mise en place d’une architecture permettant le remplacement ou la répartition multi-APIs ;
    * **respect strict des politiques de volumétrie et de fréquence** afin d’éviter tout blocage ;
    * stockage en base des données enrichies (altimétrie, commune) pour éviter les appels répétés.
* **Limites de licences cartographiques** : respect des règles OSM, mise en cache des tuiles et clustering des marqueurs.
* **Disponibilité des services externes** : stratégie de fallback et modularité pour maintenir le service même en cas d’indisponibilité partielle.

Références :

* Site officiel geocaching.com
* GPX namespaces :

  * [http://www.groundspeak.com/cache/1/0/1](http://www.groundspeak.com/cache/1/0/1)
  * [http://www.gsak.net/xmlv1/6](http://www.gsak.net/xmlv1/6)
  * [http://www.cgeo.org/wptext/1/0](http://www.cgeo.org/wptext/1/0)
  * [http://www.topografix.com/GPX/1/0](http://www.topografix.com/GPX/1/0)

## 1.14 🇫🇷 GeoChallenge Tracker - Descriptif projet

**GeoChallenge Tracker** est une application web conçue pour la communauté des géocacheurs souhaitant aller au-delà de la simple recherche de caches en participant à des **challenges** thématiques. Elle fournit un environnement complet pour **définir, suivre et analyser** l’avancement de ces défis, tout en intégrant des fonctionnalités modernes de visualisation et d’automatisation.

L’application permet aux utilisateurs d’**importer leurs trouvailles au format GPX** (fichier ou archive ZIP). Les caches sont automatiquement reconnues et, le cas échéant, associées à des challenges existants. Des mécanismes d’auto-création de challenges à partir des caches importées facilitent la mise en route pour l’utilisateur. L’API expose également des fonctions de filtrage avancé des caches par type, taille, attributs, période de placement ou encore par périmètre géographique (bounding box ou rayon de recherche via un index 2dsphere).

Une fois les caches importées, l’utilisateur peut accéder à la liste de ses **UserChallenges**, suivre leur statut (pending, accepted, completed…), et gérer leurs tâches associées. Chaque challenge est défini sous forme d’arbres logiques (AST) décrivant les conditions à remplir : par exemple nombre minimal de caches d’un type donné, difficulté cumulée, altitude totale, ou combinaison de plusieurs critères. L’API évalue régulièrement la progression et génère des **snapshots** horodatés, permettant de visualiser l’évolution dans le temps comme une **série temporelle**. Des estimations de complétion sont calculées et présentées à l’utilisateur.

L’application ne se limite pas au suivi global : elle calcule aussi des **targets** (caches candidates à rechercher) pour maximiser les chances de réussite d’un challenge. Ces targets sont filtrables par proximité géographique (autour d’un point ou selon la localisation enregistrée de l’utilisateur), par score ou par pertinence, et peuvent être consultées challenge par challenge ou dans une vue consolidée.

Côté technique, GeoChallenge Tracker repose sur un backend en **FastAPI** couplé à **MongoDB Atlas**, un frontend moderne basé sur **Vue.js** et **Vite**, et des services conteneurisés via **Docker**. La cartographie est assurée par **OpenStreetMap** et les traitements incluent la mise à jour automatique des altitudes de caches. Des tests TDD et E2E garantissent la robustesse de l’ensemble.

En résumé, GeoChallenge Tracker apporte aux géocacheurs un **outil libre, moderne et puissant**, qui combine suivi personnalisé, recommandations intelligentes et visualisations géographiques pour relever des défis toujours plus ambitieux.

## 1.15 🇬🇧 GeoChallenge Tracker - Project description

**GeoChallenge Tracker** is a web application designed for the geocaching community eager to go beyond simple cache hunting by taking part in thematic **challenges**. It offers a comprehensive environment to **define, monitor, and analyze** challenge progress, with modern visualization tools and automated workflows.

Users can **import their finds in GPX format** (single file or ZIP archive). Imported caches are automatically recognized and, when relevant, linked to existing challenges. The system also supports auto-creation of challenges based on imported caches, making onboarding straightforward. The API provides advanced filtering options to search caches by type, size, attributes, placement date, or geographical scope (bounding box or radius search powered by a 2dsphere index).

Once caches are loaded, users can explore their list of **UserChallenges**, track their status (pending, accepted, completed, etc.), and manage the associated tasks. Each challenge is defined as a logical tree (AST) representing the rules to meet—such as a minimum number of caches of a certain type, cumulative difficulty thresholds, altitude sums, or combinations of multiple conditions. The API evaluates progress on a regular basis and produces **timestamped snapshots**, enabling users to view their evolution as a **time series**. Estimated completion dates are also provided to help planning.

Beyond overall progress tracking, the application computes **targets** (candidate caches to look for) to maximize a user’s chance of completing a challenge. These targets can be filtered by geographical proximity (around a given point or based on the user’s last recorded location), sorted by score or relevance, and displayed either per challenge or in a consolidated view.

From a technical perspective, GeoChallenge Tracker is built on a **FastAPI** backend with **MongoDB Atlas**, a modern frontend using **Vue.js** and **Vite**, and a containerized deployment with **Docker**. Maps are rendered with **OpenStreetMap**, while elevation data is updated automatically. The project relies on TDD and E2E testing to ensure reliability and robustness.

In short, GeoChallenge Tracker delivers a **modern, open, and powerful tool** for geocachers, combining personalized tracking, intelligent recommendations, and geographical visualizations to help them take on ever more ambitious challenges.
