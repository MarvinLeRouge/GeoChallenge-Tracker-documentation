# 8. DevOps — Conteneurisation, Déploiement et Git

## 8.1 Objectifs
- **Cohérence d’exécution** : garantir le même comportement entre dev et prod, bien que les **configurations diffèrent** (montages & hot reload en dev, images figées et Nginx en prod).
- **Intégration continue** : tests automatiques et builds sur GitHub Actions.
- **Déploiement continu** : mise en production automatisée sur un VPS.
- **Sécurité** : gestion des secrets hors code (JWT, MongoDB, SMTP).
- **Suivi du code** : workflow Git structuré par contexte (backend / frontend).

## 8.2 Conteneurisation (Docker)

### 8.2.1 Images
- **Backend** : Python + FastAPI, image slim avec Uvicorn.
- **Frontend** : Vue.js (Vite) → artefacts statiques servis par Nginx.
- **Base de données** : MongoDB Atlas (pas de conteneur en prod).

### 8.2.2 docker-compose (développement)
- Services : backend, frontend, éventuellement reverse proxy.
- Variables d’environnement chargées depuis `.env.development`.
- Hot reload activé pour le confort développeur.

**Exemple**
```bash
docker compose up -d --build
docker compose exec backend pytest -q
```

> **Note dev vs prod** — En développement, `docker-compose` utilise des **volumes montés** et le **hot reload** (ports exposés).  
> En production, les services sont déployés à partir d’**images versionnées** (sans hot reload), le frontend est servi par **Nginx** et la configuration provient d’un **fichier d’environnement dédié**.

## 8.3 Git — Convention de branches et workflow

### 8.3.1 Nommage des branches
Le projet étant séparé en **API** et **interface**, les branches sont préfixées par leur contexte :

- `backend/<section>` : auth, caches, challenges, progress, targets, tests…
- `frontend/<section>` : auth, appshell, ui-foundation, home…
- Maintenance : ex. `backend/fix/sendmail`.
- Branche utilitaire : `install` (initialisation de la structure du projet).

Ce nommage évite les collisions front/back (qui apparaissent avec un simple `feature/*`) et reflète la logique de développement.

### 8.3.2 Politique de fusion
- Développement sur `backend/<section>` ou `frontend/<section>`.
- Une fois validé, merge dans `backend/main` ou `frontend/main`.
- **Main global** : seule source de vérité pour la production, alimenté uniquement par `backend/main` ou `frontend/main`.

Ce workflow garantit un historique lisible et réduit les risques de régressions.

## 8.4 CI/CD et déploiement

### 8.4.1 GitHub Action (build & deploy réels)

Le workflow suivant illustre le **build** des images (backend & frontend) avec **tags `latest` et `sha-<commit>`**, puis un **déploiement SSH** vers un **utilisateur dédié** sur le VPS.  
Il met en évidence :
- la **normalisation du nom** `owner/repo` en minuscules (pour GHCR),
- l’usage d’une **clé SSH dédiée au déploiement**,
- des `echo` de **journalisation** de chaque étape côté VPS,
- et la **lecture centralisée** des variables d’environnement depuis `../shared/env/app.env`.

```yaml
name: build-and-push

on:
  push:
    branches: ["main"]
  workflow_dispatch: {}

permissions:
  contents: read
  packages: write

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      owner_lc: ${{ steps.names.outputs.owner_lc }}
      repo_lc: ${{ steps.names.outputs.repo_lc }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Compute lowercase owner & repo
        id: names
        run: |
          REPO_LC="${GITHUB_REPOSITORY##*/}"
          OWNER_LC="${GITHUB_REPOSITORY_OWNER}"
          echo "REPO_LC=${REPO_LC,,}" >> $GITHUB_ENV
          echo "OWNER_LC=${OWNER_LC,,}" >> $GITHUB_ENV
          echo "owner_lc=${OWNER_LC,,}" >> $GITHUB_OUTPUT
          echo "repo_lc=${REPO_LC,,}" >> $GITHUB_OUTPUT

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to GHCR (GITHUB_TOKEN)
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build & Push backend
        uses: docker/build-push-action@v6
        with:
          context: ./backend
          file: ./backend/Dockerfile
          push: true
          tags: |
            ghcr.io/${{ env.OWNER_LC }}/${{ env.REPO_LC }}/backend:latest
            ghcr.io/${{ env.OWNER_LC }}/${{ env.REPO_LC }}/backend:sha-${{ github.sha }}

      - name: Build & Push frontend
        uses: docker/build-push-action@v6
        with:
          context: ./frontend
          file: ./frontend/Dockerfile
          push: true
          tags: |
            ghcr.io/${{ env.OWNER_LC }}/${{ env.REPO_LC }}/frontend:latest
            ghcr.io/${{ env.OWNER_LC }}/${{ env.REPO_LC }}/frontend:sha-${{ github.sha }}

  deploy:
    runs-on: ubuntu-latest
    needs: build
    env:
      OWNER_LC: ${{ needs.build.outputs.owner_lc }}
      REPO_LC: ${{ needs.build.outputs.repo_lc }}
      SHA_TAG: sha-${{ github.sha }}

    steps:
      - name: Deploy over SSH (compose pull + up) — Variante A (latest)
        uses: appleboy/ssh-action@v1.2.0
        with:
          host: ${{ secrets.DEPLOY_SSH_HOST }}
          username: ${{ secrets.DEPLOY_SSH_USER }}
          key: ${{ secrets.DEPLOY_SSH_PRIVATE_KEY }}
          script_stop: true
          script: |
            set -Eeuo pipefail

            echo "== whoami ==" && whoami
            echo "== date ==" && date -Is
            echo "== go to compose dir =="

            cd /home/deploy/apps/gctracker/compose
            echo "PWD: $(pwd)"
            echo "== list files =="
            ls -la

            echo "== show env entries from ../shared/env/app.env =="
            grep -E '^(IMAGE_BACKEND|IMAGE_FRONTEND|BACKEND_PORT|FRONTEND_PORT)=' ../shared/env/app.env || true

            echo "== docker compose version =="
            docker compose version

            echo "== preview resolved compose (with --env-file) =="
            docker compose --env-file ../shared/env/app.env config

            echo "== pull images =="
            docker compose --env-file ../shared/env/app.env pull

            echo "== up -d (remove orphans) =="
            docker compose --env-file ../shared/env/app.env up -d --remove-orphans

            echo "== ps =="
            docker compose --env-file ../shared/env/app.env ps
```


### 8.4.2 Déploiement distant sans script local

Le déploiement est **déclenché depuis GitHub Actions** via une connexion **SSH** à un **utilisateur dédié** (`deploy`) sur le VPS.  
Les commandes `docker compose` sont exécutées **à distance**, en **chargeant un fichier d’environnement centralisé** (`../shared/env/app.env`).  
Les `echo` présents dans le workflow permettent de **tracer finement** chaque étape (qui, quand, quoi, où).

> **Variante B (optionnelle)** : un script local `deploy.sh` peut encapsuler ces commandes si l’on souhaite déclencher un déploiement manuel côté VPS.

Ce script tire les nouvelles images, relance les services et nettoie les images obsolètes.  
Les secrets applicatifs restent stockés localement sur le VPS (`.env` sécurisé).

### 8.4.3 Arborescence VPS & gestion des variables

L’arborescence suivante centralise la configuration et sépare **compose** (déploiement) des **variables d’environnement** (conf), lesquels ont été réparties entre un fichier de configuration et un fichier de secrets :

/home/deploy/apps/gctracker/
├─ compose/ # docker-compose.yml (prod)
│    └─ docker-compose.yml
└─ shared/
     └─ env/
         └─ app.env # variables d'environnement prod
         └─ secrets.env # secrets d'environnement prod

**`app.env`** (extraits) :
```env
IMAGE_BACKEND=ghcr.io/<owner>/<repo>/backend:latest
IMAGE_FRONTEND=ghcr.io/<owner>/<repo>/frontend:latest

BACKEND_PORT=8000
FRONTEND_PORT=80
```

**`secrets.env`** (extraits) :
```env
MONGODB_URI=...
JWT_SECRET_KEY=...
JWT_ALGORITHM=HS256
SMTP_HOST=...
SMTP_USER=...
SMTP_PASSWORD=...
```

> Avantages : séparation nette **code/config**, **rotation** des secrets facilitée, et **reproductibilité** des déploiements.

> **Sécurité du déploiement**
> - Utilisateur **dédié** (`deploy`) avec droits strictement nécessaires.
> - **Clé SSH** dédiée stockée dans **GitHub Secrets** (`DEPLOY_SSH_PRIVATE_KEY`).
> - **Aucune** variable sensible transitant par l’Action : tout est chargé via `../shared/env/app.env` côté VPS.
> - **Images versionnées** (`latest` + `sha-<commit>`) pour permettre un **rollback** rapide.
