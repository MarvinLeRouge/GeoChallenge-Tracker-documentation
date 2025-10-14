# 2. Compétences mobilisées

## 2.1 Développer une application sécurisée

La première catégorie de compétences concerne la capacité à développer une application sécurisée, depuis l’installation de l’environnement de travail jusqu’à la gestion du projet.

* **Installer et configurer son environnement de travail en fonction du projet**

  * Mise en place d’un environnement Dockerisé pour assurer la reproductibilité.
  * Configuration du backend avec FastAPI et du frontend avec Vue.js.

* **Développer des interfaces utilisateur**

  * Interfaces responsives construites avec Vue 3 et Tailwind CSS.
  * Intégration de composants cartographiques interactifs (Leaflet) avec clustering et *tile caching*.
  * Optimisation des performances dans une démarche de *green computing via performance optimizing*.

* **Développer des composants métier**

  * Parsing de fichiers GPX multi-namespaces (C\:Geo, Groundspeak, GSAK, Topografix).
  * Conception et manipulation de grammaires AST pour exprimer et traiter les conditions des challenges.
  * Calculs de projections d’avancement et génération de séries temporelles.
  * Moteur de filtrage par condition et gestion des doublons.

* **Contribuer à la gestion d’un projet informatique**

  * Suivi sur GitHub (issues, milestones, kanban).
  * Organisation du planning et intégration continue via GitHub Actions.

## 2.2 Concevoir et développer une application sécurisée organisée en couches

La deuxième catégorie porte sur la conception d’une application structurée, respectant une architecture en couches et intégrant une base de données adaptée.

* **Analyser les besoins et maquetter une application**

  * Rédaction du cahier des charges (expression du besoin).
  * Réalisation de wireframes des vues principales.
* **Définir l’architecture logicielle d’une application**

  * Architecture découpée : backend FastAPI (API REST) et frontend Vue.js.
  * Séparation stricte des responsabilités (contrôleurs, composants métier, données).
* **Concevoir et mettre en place une base de données relationnelle**

  * Transposition aux besoins du projet avec MongoDB (NoSQL).
  * Modélisation documentaire adaptée à la variabilité des caches et de leurs attributs.
  * Indexation pour requêtes multi-critères et optimisation de la volumétrie.
* **Développer des composants d’accès aux données SQL et NoSQL**

  * Accès aux données utilisateur via MongoDB (CRUD, indexation, agrégations).
  * Sécurisation des accès et séparation stricte par utilisateur.

## 2.3 Préparer le déploiement d’une application sécurisée

Enfin, les compétences mobilisées concernent la préparation du déploiement et la mise en production dans une démarche DevOps.

* **Préparer et exécuter les plans de tests d’une application**

  * Tests unitaires backend (Pytest) avec approche TDD.
  * Tests end-to-end frontend (Cypress).
  * Tests fonctionnels de bout en bout.
* **Préparer et documenter le déploiement d’une application**

  * Fichiers `Dockerfile` et `docker-compose.yml` pour la conteneurisation.
  * Documentation des variables d’environnement et procédures de lancement.
* **Contribuer à la mise en production dans une démarche DevOps**

  * CI/CD via GitHub Actions (tests, build, déploiement automatisé).
  * Déploiement en environnement Railway et base MongoDB Atlas.
  * Conteneurisation pour homogénéité dev/prod et réduction des erreurs humaines.

## 2.4 Technologies utilisées

Ces compétences se traduisent concrètement par l’utilisation des technologies suivantes :

* **Backend** : FastAPI (Python).
* **Frontend** : Vue.js 3, Tailwind CSS.
* **Base de données** : MongoDB (NoSQL).
* **Cartographie** : Leaflet + OpenStreetMap (clustering, *tile caching*).
* **Conteneurisation / DevOps** : Docker, docker-compose, GitHub Actions.
* **Tests** : Pytest (backend), Cypress (frontend).
* **Sécurité** : JWT, chiffrement des mots de passe, validation des entrées.
* **APIs externes** : services opendata (altimétrie, localisation).
