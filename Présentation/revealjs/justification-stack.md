# Frontend

## Vue.js
- **Courbe d’apprentissage & communauté** : framework mature, docs claires, écosystème riche (composants, tooling).
- **Performance & maintenabilité** : réactivité fine sans sur-ingénierie, structure SFC (lisibilité, testabilité).
- **Adapté mobile-first** : rendu rapide, DOM minimal, bon support des PWA si extension future.

## Pinia (state management)
- **Simplicité** : API moderne, typage facile, moins verbeux que Vuex.
- **Prévisible** : flux de données clair, conditions de course limitées.
- **Testable** : stores isolables => tests unitaires ciblés.

## Vite (bundler/dev server)
- **Démarrage instantané** : HMR rapide => itérations UI fluides.
- **Build performant** : optimisation automatique, code-splitting par défaut.
- **Sobriété** : temps CPU réduit en dev => gains énergie.

## Leaflet (cartographie)
- **Open-source & léger** : pas de verrou éditeur, coûts nuls.
- **Écosystème** : clustering, contrôles, fonds carto variés.
- **Respect OSM** : intégration naturelle avec politiques d’usage (rate limit + cache tuiles).

## DOMPurify
- **Sécurité front** : neutralise XSS sur contenus HTML dynamiques.
- **Responsabilité** : défense en profondeur côté client, complément du backend.

---

# Backend

## Python 3.11
- **Écosystème data & async** : librairies matures (asyncio, parsing, tests).
- **Performance** : améliorations 3.11 (interpréteur, typing) => latences maîtrisées.
- **Lisibilité** : code expressif => maintenance facilitée.

## FastAPI
- **Rapidité de dev** : déclaratif, schémas auto (OpenAPI), validation intégrée.
- **Async natif** : I/O non bloquant (Mongo, appels externes).
- **Perf & DX** : très bon P95, docs auto pour les testeurs.

## Pydantic
- **Validation stricte** : fail-fast, contrat d’API explicite.
- **Sérialisation** : conversion types (dates, enums) fiable.
- **Sécurité** : surface d’attaque réduite (entrées contrôlées).

## JWT (+ refresh)
- **Stateless** : pas de session serveur, scaling horizontal simplifié.
- **UX** : renouvellement discret, sessions longues maîtrisées.
- **Sécurité** : rotation, scopes/roles (user/admin).

---

# Données

## MongoDB
- **Modèle documentaire** : colle aux structures GPX/challenges (souple, évolutif).
- **Géospatiale native** : index **2dsphere**, `$geoNear` pour tri par distance.
- **Agrégations** : pipelines => projections compactes, latence réseau réduite.

## Indexation & agrégations
- **2dsphere + champs clés** : requêtes proches O(log N) en pratique.
- **Pipelines côté serveur** : moins de transfert, CPU client épargné.
- **Sobriété** : moins d’allers-retours => empreinte réseau réduite.

## Snapshots (progression)
- **Historisation** : séries temporelles prêtes à l’analyse.
- **Performances** : lectures rapides sans recalcul intégral.
- **Traçabilité** : explication de l’évolution (auditable).

---

# Services externes & parsing

## OpenTopoData (provider altimétrie)
- **Qualité/coût** : service public/open, budget maîtrisé.
- **Rate limiting** : quotas respectés, backoff + batch => stabilité.
- **Résilience** : erreurs gérées, résultats partiels > échec total.
- **Abstraction service simple** : évolution facilitée.

## Parser GPX (multi-namespaces)
- **Interopérabilité** : compatibilité c:geo, GSAK, Groundspeak, etc.
- **Robustesse** : validation stricte, erreurs localisées.
- **Évolutivité** : ajout d’attributs sans casser le pipeline.
- **Anticipation** : prise en charge future d'autres formats.

---

# Qualité, sécurité, conformité

## Tests — Pytest / Vitest / Playwright
- **Pyramide réaliste** : majorité unitaires, E2E ciblés => coût/valeur optimisés.
- **Objectif couverture > 70%** : réassurance sur refactors.
- **Automatisation** : scénarios reproductibles pour la soutenance.

## pip-audit / npm audit
- **Veille continue** : détection CVE sur dépendances.
- **Réactivité** : patchs guidés, versions sûres.
- **Traçabilité** : démarche sécurité démontrable au jury.

## Defense in Depth / Fail Secure
- **Multicouche** : JWT + Pydantic + DOMPurify + CORS + rate limit.
- **Échec sûr** : en cas d’erreur, rejets contrôlés (422/413/403), pas de fuite.
- **Conformité d’usage** : respect OSM/OpenTopoData => projet responsable.

---

# DevOps & exploitation

## Docker (Compose)
- **Parité env** : “ça marche chez moi” = “ça marche en prod”.
- **Reproductibilité** : onboarding testeurs en minutes.
- **Isolation** : dépendances cloisonnées, risques conflit réduits.

## CI/CD/CC (GitHub Actions/Projects)
- **Intégration continue** : tests, lint, audit à chaque commit.
- **Déploiements fiables** : pipeline clair, rollback possible.
- **Traçabilité** : issues <=> commits <=> releases (dossier & annexes).
- **Communication** : L'automatisation évite tout oubli de communication et contraint le développeur à l'ouverture.

## Logging & métriques (pratiques)
- **Observabilité** : logs actionnables (erreurs, temps, quotas).
- **Diagnostics rapides** : MTTR réduit.
- **Amélioration continue** : décisions guidées par données.

---

# Alternatives envisagées (et pourquoi écartées)

- **React / Angular** : plus lourds pour le périmètre MVP ; Vue = vitesse de dev + simplicité.
- **PostgreSQL + PostGIS** : excellent en géo, mais surcoût de modélisation par rapport aux documents GPX & snapshots.
- **Auth sessions serveur** : moins scalable que JWT stateless.
- **Services carto propriétaires** : coût/licence/verrou => OSM + Leaflet suffisent pour l’usage.
