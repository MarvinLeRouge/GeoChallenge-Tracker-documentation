
# GeoChallenge Tracker — Plan Frontend (livraison par vagues)
_Date: 2025-08-28_

> Objectif&nbsp;: sortir **vite** des pages **fonctionnelles**. Design minimal (outil), focus UX/perfs.  
> Hypothèses&nbsp;: Vue 3 + Vite + Vue Router + Pinia; Leaflet + Supercluster pour cartes; Service Worker pour caching tuiles.

---

## Sommaire
- [Éléments communs (socle)](#elements-communs-socle)
- [Arborescence des routes (sitemap)](#arborescence-des-routes-sitemap)
- [Vague 0 — AppShell + Auth + Page d’accueil (dummy)](#vague-0--appshell--auth--page-daccueil-dummy)
- [Vague 1 — Import GPX](#vague-1--import-gpx)
- [Vague 2 — Caches (liste + carte)](#vague-2--caches-liste--carte)
- [Vague 3 — Mes challenges (liste → détail → progression)](#vague-3--mes-challenges-liste--detail--progression)
- [Vague 4 — Targets par challenge (carte OSM + clustering)](#vague-4--targets-par-challenge-carte-osm--clustering)
- [Vague 5 — Targets à proximité (UC & tous challenges)](#vague-5--targets-a-proximite-uc--tous-challenges)
- [Vague 6 — Profil & localisation](#vague-6--profil--localisation)
- [Vague 7 — Admin & maintenance](#vague-7--admin--maintenance)
- [Branches Git (par salve)](#branches-git-par-salve)
- [Annexes (contrats API & DoD synthétique)](#annexes-contrats-api--dod-synthetique)

---

## Éléments communs (socle)

### Stack & conventions
- **UI**&nbsp;: Vue 3 + Vite; **routing**&nbsp;: Vue Router; **state**&nbsp;: Pinia; **HTTP**&nbsp;: axios; **i18n** minimal FR.
- **Carto**&nbsp;: Leaflet (raster) + **Supercluster** pour le clustering; icônes simples (SVG).
- **PWA / SW**&nbsp;: Workbox. Tuiles OSM&nbsp;: stratégie **Stale-While-Revalidate** + limite LRU.
- **Types**&nbsp;: DTO légers (Typescript conseillé), adapters `api → ui`.
- **UX communs**&nbsp;: toasts, spinners, skeletons, empty states.

### AppShell
- **Header** (menu principal, quick actions), **SideNav** (contexte), **Content** (`<router-view>`), **Toasts**.
- **Guards**&nbsp;: routes protégées (auth/admin), redirection login si 401/403.

### Auth & tokens
- Pages&nbsp;: Login, Register, Verify Email, Resend.
- **Intercepteur axios**&nbsp;: sur 401 → **refresh** → retry; sinon logout + redirect `/login`.
- Stockage tokens&nbsp;: mémoire + `localStorage` (access court + refresh), horodatage pour proactive refresh.

### Erreurs & validation
- Mapping 4xx/5xx vers messages utilisateur. Affichage inline + toast; capture réseau (devtools).

### Cartes & perf
- **Clustering client** via Supercluster sur data déjà paginée; pagination progressive → “Load more on map”.
- **BBox flows**&nbsp;: debounce pan/zoom → fetch côté serveur; réconciliation locale.
- **Markers**&nbsp;: popup concise (cache/target), CTA “Voir détail”.

### Accessibilité & perf
- Focus states, labels explicites; lazy-loading routes; code-splitting par page.

---

## Arborescence des routes (sitemap)
```
/
├─ /login
├─ /register
├─ /verify-email
├─ /resend-verification
├─ /caches
│  ├─ /caches/list
│  ├─ /caches/map
│  └─ /caches/:gcOrId
├─ /import
├─ /my/challenges
│  ├─ /my/challenges/:ucId
│  │  ├─ /my/challenges/:ucId/progress
│  │  ├─ /my/challenges/:ucId/tasks
│  │  └─ /my/challenges/:ucId/targets
├─ /my/targets
│  ├─ /my/targets/nearby
│  └─ /my/targets/all
├─ /profile/location
└─ /admin
   ├─ /admin/maintenance
   ├─ /admin/challenges-refresh
   └─ /admin/elevation-backfill
```

---

## Vague 0 — AppShell + Auth + Page d’accueil (dummy)
**But**&nbsp;: socle prêt + auth opérationnelle + page d’accueil de test.

**Livrables**
- AppShell (header, sidenav, toasts), guards.
- Pages&nbsp;: `/login`, `/register`, `/verify-email`, `/resend-verification`.
- Intercepteurs axios (refresh, retry, logout).
- **Accueil dummy** `/`&nbsp;: liens vers Import, Caches, Mes challenges.

**DoD**
- Connexion/inscription/validation OK; refresh auto.
- 401 → redirect login, 403 → page dédiée.
- Lighthouse perf/base OK (pas de blocant).

---

## Vague 1 — Import GPX
**But**&nbsp;: injecter rapidement des caches pour alimenter les vues suivantes.

**Livrables**
- Page `/import`&nbsp;: dropzone, drag-n-drop, validation extension/taille.
- Appel `POST /caches/upload-gpx?found=`.
- Résumé d’import&nbsp;: {{importées, ignorées, erreurs}} + CTA “Voir caches”.

**DoD**
- Fichier volumineux supporté (progress UI).
- Gestion erreurs lisible (format invalide, taille, réseau).
- Redirection vers `/caches/list` en 1 clic.

---

## Vague 2 — Caches (liste + carte)
**But**&nbsp;: vérifier l’ingest et offrir la consultation rapide.

**Livrables**
- `/caches/list`&nbsp;: filtres (texte, type, D/T…), tri, pagination.
- `/caches/map`&nbsp;: carte Leaflet, clustering, bbox fetch; popup → lien détail.
- `/caches/:gcOrId`&nbsp;: fiche cache minimaliste.

**DoD**
- Liste et carte cohérentes avec mêmes filtres.
- Pan/zoom déclenche fetch bbox (debounce).
- Temps de rendu < 200ms pour 5k points (avec clustering).

---

## Vague 3 — Mes challenges (liste → détail → progression)
**But**&nbsp;: cœur métier côté utilisateur.

**Livrables**
- `/my/challenges`&nbsp;: liste + filtres statut.
- `/my/challenges/:ucId`&nbsp;: détails + actions statut/notes.
- `/my/challenges/:ucId/progress`&nbsp;: progression + bouton “Recalculer”.

**DoD**
- PATCH optimiste + rollback si 422.
- Recalcul progression feedback (spinner + toast).

---

## Vague 4 — Targets par challenge (carte OSM + clustering)
**But**&nbsp;: recommandations visualisées.

**Livrables**
- `/my/challenges/:ucId/targets`&nbsp;: liste + carte cluster.
- Action “Évaluer” (POST evaluate) avec options simples (force/zone).

**DoD**
- Markers clairs&nbsp;: target vs cache standard.
- Tri par score/distance.

---

## Vague 5 — Targets à proximité (UC & tous challenges)
**But**&nbsp;: préparer sorties terrain.

**Livrables**
- `/my/targets/nearby`&nbsp;: inputs lat/lon/rayon (+ “autour de moi”).
- `/my/targets/all`&nbsp;: vue agrégée, mini-carte, filtres statut.

**DoD**
- Fallback sur dernière localisation profil.
- Performance OK sur clustering multi-UC.

---

## Vague 6 — Profil & localisation
**Livrables**
- `/profile/location`&nbsp;: GET/PUT localisation (ville ou lat/lon).

**DoD**
- Validation coordonnées, feedback clair.

---

## Vague 7 — Admin & maintenance
**Livrables**
- `/admin/maintenance`&nbsp;: GET/POST maintenance.
- `/admin/challenges-refresh`&nbsp;: POST refresh-from-caches.
- `/admin/elevation-backfill`&nbsp;: POST backfill (limit/page_size/dry_run).

**DoD**
- Restreint admin, logs d’action.

---

## Branches Git (par salve)
- `feat/fe-v0-appshell-auth` — Vague 0 (socle + auth + dummy home)
- `feat/fe-v1-import-gpx` — Vague 1 (import)
- `feat/fe-v2-caches-list-map` — Vague 2 (caches)
- `feat/fe-v3-my-challenges-core` — Vague 3 (challenges)
- `feat/fe-v4-targets-by-uc` — Vague 4 (targets UC)
- `feat/fe-v5-targets-nearby` — Vague 5 (nearby/all)
- `feat/fe-v6-profile-location` — Vague 6 (profil)
- `feat/fe-v7-admin` — Vague 7 (admin)
- (optionnel) `chore/fe-sw-tiles-cache` — SW & cache tuiles
- (optionnel) `chore/fe-ci-lint-format` — CI, ESLint/Prettier

**Convention**&nbsp;: PR par vague vers `develop`, squash merge; `main` = releases.

---

## Annexes (contrats API & DoD synthétique)

### Contrats API (raccourcis)
- **Auth**&nbsp;: `/auth/login`, `/auth/refresh`, `/auth/register`, `/auth/verify-email`, `/auth/resend-verification`.
- **Import GPX**&nbsp;: `POST /caches/upload-gpx?found=`.
- **Caches**&nbsp;: `/caches/by-filter`, `/caches/within-bbox`, `/caches/within-radius`, `/caches/{gc}`, `/caches/by-id/{id}`.
- **Challenges**&nbsp;: `/my/challenges`, `/my/challenges/{ucId}`, `/my/challenges/{ucId}/progress` (GET + POST evaluate).
- **Targets**&nbsp;: `/my/challenges/{ucId}/targets` (GET + POST evaluate), `/my/targets`, `/my/targets/nearby`.
- **Profil**&nbsp;: `/my/profile/location` (GET/PUT).
- **Admin**&nbsp;: `/maintenance`, `/challenges/refresh-from-caches`, `/caches_elevation/caches/elevation/backfill`.

### DoD (checklist générique)
- Tests manuels clés passés (auth, erreurs réseau, gros fichiers).
- States synchronisés (listes ↔ cartes), loaders/empty states présents.
- Accessibilité basique (tab, aria-labels). 
- Perf&nbsp;: pas de jank notable; clustering actif sur >2k points.
