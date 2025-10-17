<!-- clearpage -->
# 1. Liste des compétences mises en œuvre

## 1.1 Bloc 1&nbsp;: Développer une application sécurisée

### 1.1.1 Installer et configurer son environnement de travail
- Environnement Docker multi-services avec docker-compose
- Configuration Python 3.11, FastAPI, MongoDB Atlas, Vue.js
- Outils&nbsp;: VS Code, ESLint/Prettier, debugger FastAPI
- Gestion des secrets via variables d'environnement  
  *Objectifs*&nbsp;: séparation stricte de la configuration et des secrets en production, non dissémination des secrets entre les différentes entités impliquées (github, services tiers liés au déploiement)

### 1.1.2 Développer des interfaces utilisateur
- Framework Vue 3 avec Composition API et TypeScript
- Design responsive mobile-first (Tailwind CSS, Flowbite)
- Cartographie interactive Leaflet avec clustering et tile caching
- Gestion d'état Pinia
- Optimisation des performances dans une démarche de *green computing*

### 1.1.3 Développer des composants métier
- Parser GPX multi-namespace pour extraction des informations des caches
- Moteur de règles AST pour évaluation des challenges
- Moteur de filtrage par condition et gestion des doublons
- Service de progression avec calculs et projections, génération de séries temporelles
- Algorithme de scoring pour identification des cibles

### 1.1.4 Contribuer à la gestion d'un projet
- Méthodologie Agile adaptée, suivi de projet Github (issues, milestones, kanban)
- CI/CD avec GitHub Actions
- Information des acteurs du projet via Github Actions
- Documentation technique complète
- Suivi qualité (linters, formatters)

## 1.2 Bloc 2&nbsp;: Concevoir une application organisée en couches

### 1.2.1 Analyser les besoins et maquetter
- Analyse du domaine geocaching, et des besoins des pratiquants de challenges
- Cahier des charges détaillé
- Wireframes et prototypage

### 1.2.2 Définir l'architecture logicielle
- Architecture 3-tiers&nbsp;: Vue / FastAPI / MongoDB
- Séparation des responsabilités
- Pattern Repository, architecture hexagonale

### 1.2.3 Concevoir la base de données
- Modélisation documentaire NoSQL / MongoDB, adaptée à la variabilité des caches et de leurs attributs
- Indexation stratégique (géospatiale, composée)
- Agrégations complexes, optimisation, dénormalisation

### 1.2.4 Développer les composants d'accès aux données
- ODM avec Pydantic
- CRUD générique MongoDB
- Transactions, cache référentiels
- Sécurisation des accès à la base de données par whitelist

<!-- pagebreak -->
## 1.3 Bloc 3&nbsp;: Préparer le déploiement sécurisé

### 1.3.1 Préparer et exécuter les tests
- Tests unitaires (pytest, Vitest)
- Tests d'intégration et E2E
- Tests de coverage
- Tests utilisateurs

### 1.3.2 Préparer et documenter le déploiement
- Dockerisation multi-stage
- Documentation complète
- Configuration externalisée

### 1.3.3 Contribuer à la mise en production DevOps
- CI/CD automatisé GitHub Actions (tests, build, déploiement automatisé, diffusion automatisée d'information)
- Déploiement blue-green sur VPS
- Monitoring et rollback
