
# Frontend — Docker multi‑étapes (dev/build/prod) & Proxy API

> Projet: GeoChallenge Tracker — Frontend Vue 3 + Vite, backend FastAPI.  
> Objectif: documenter clairement **pourquoi** et **comment** on utilise trois étapes (dev, build, prod) et le **proxy /api** côté Vite (dev) / Nginx (prod).

---

## TL;DR — Pourquoi 3 étapes ?

| Étape | Image | Usage | Caractéristiques | Avantages |
|------|------|------|------------------|-----------|
| **dev** | `node:20-alpine` | Développement local (Docker) | Vite **+ HMR**, watch fichiers, proxy `/api` côté Vite | Boucle rapide, pas de CORS, code monté en volume |
| **build** | `node:20-alpine` | **Compilation** | `npm ci` + `npm run build` → produit `/dist` | Artefacts optimisés, cache de build efficace |
| **prod** | `nginx:alpine` | Exécution en production | Sert **fichiers statiques** `/dist` + proxy `/api` côté **Nginx** | Image finale **légère**, rapide, sûre |

---

## Vue d’ensemble — Flux des requêtes

### En **dev** (Vite)
```
Navigateur  →  http://localhost:5173  →  [Vite Dev Server]
               └─ /api/...  → proxy Vite →  http://backend:8000/...
```
- Pas de CORS&nbsp;: le navigateur parle à Vite; Vite relaie vers le backend Docker via son **nom de service `backend`**.

### En **prod** (Nginx)
```
Navigateur  →  http://<frontend-host>/  →  [Nginx]
               ├─ fichiers /dist
               └─ /api/...  → proxy Nginx →  http://backend:8000/...
```
- Même URL `/api` côté client, mais le proxy est assuré par **Nginx**, pas Vite.

---

## Détails par étape

### 1) **dev** — Vite + HMR
- Image Node (npm/Node disponibles), serveur Vite exposé sur **5173** avec **HMR**.
- Le code est monté en **volume**: sauvegarde = reload immédiat.
- Proxy `/api` défini dans `vite.config.ts` (évite CORS).  
- Watch Docker-friendly via **polling** (CHOKIDAR).

**Extrait `vite.config.ts` (dev)**
```ts
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    host: true,               // 0.0.0.0 (Docker)
    port: 5173,
    watch: { usePolling: true, interval: 100 },
    proxy: {
      '/api': {
        target: 'http://backend:8000', // nom du service Docker backend
        changeOrigin: true,
        rewrite: p => p.replace(/^\/api/, '')
      }
    }
  }
})
```

**Service `docker-compose.yml` (dev)**  
```yaml
frontend:
  build:
    context: ./frontend
    dockerfile: Dockerfile
    target: dev
  container_name: geo-frontend
  environment:
    - CHOKIDAR_USEPOLLING=true
  depends_on: [backend]
  ports:
    - "5173:5173"
  volumes:
    - ./frontend:/app
    - /app/node_modules
```

### 2) **build** — Compilation
- Étape intermédiaire qui **fabrique `/dist`** via `npm ci` puis `npm run build`.
- Bénéficie du **cache** Docker (si `package*.json` inchangés).
- **Jamais** déployée telle quelle.

### 3) **prod** — Nginx (statique + proxy)
- Sert les fichiers pré‑buildés de `/dist`.
- Proxy `/api` configuré dans `nginx.conf` → **même contrat d’URL** qu’en dev.

**Extrait `nginx.conf` (prod)**
```nginx
server {
  listen 80;
  root /usr/share/nginx/html;

  location /api/ {
    proxy_pass http://backend:8000/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
  }
  location / {
    try_files $uri /index.html;
  }
}
```

---

## Dockerfile multi‑étapes (complet)

```dockerfile
# ---- Dev (Vite + HMR) ----
FROM node:20-alpine AS dev
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
EXPOSE 5173
CMD ["npm","run","dev","--","--host"]

# ---- Build ----
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# ---- Prod (Nginx) ----
FROM nginx:alpine AS prod
WORKDIR /usr/share/nginx/html
COPY --from=build /app/dist ./
COPY nginx.conf /etc/nginx/conf.d/default.conf
```

---

## Commandes utiles

### Dev (Vite + HMR)
```bash
docker compose up --build
# puis http://localhost:5173
```

### Test de connectivité dans le conteneur
```bash
docker exec -it geo-frontend sh -lc "wget -qO- http://backend:8000/docs | head"
```

### Build image **prod** et run localement
```bash
# depuis ./frontend
docker build -t geochallenge-frontend --target prod .
docker run --rm -p 8080:80 --name gct-fe geochallenge-frontend
# → http://localhost:8080
```

> **Note réseau**&nbsp;: pour que Nginx atteigne `http://backend:8000`, l’instance backend doit être joignable (même docker‑network). En Compose, mettez les deux services dans le même `docker-compose.yml`.

---

## Alternatives d’URL API (si vous ne voulez pas de proxy)

- **Avec proxy** (recommandé)&nbsp;: le code frontend appelle **`/api/...`**.
- **Sans proxy**&nbsp;: utilisez une variable d’env.
  - `.env`: `VITE_API_URL=http://localhost:8000`
  - code:
    ```ts
    const baseURL = import.meta.env.VITE_API_URL || '/api'
    fetch(`${baseURL}/ping`)
    ```
  - Attention au **CORS** si vous ciblez un autre host/port.

---

## Dépannage (FAQ rapide)

- **`/api` part sur `localhost:5173/ping`** → l’appel a été fait **sans** préfixe `/api` ou le proxy n’est pas actif (vous servez un build au lieu de Vite dev).
- **`npm: not found`** → l’image finale est `nginx` (prod). En dev, utilisez la **cible `dev`** (image Node).
- **HMR ne réagit pas** → vérifiez `CHOKIDAR_USEPOLLING=true`, le montage de volume, et que vous lancez `npm run dev` (pas `vite preview`).
- **CORS** en dev → utilisez le **proxy Vite** ou ouvrez CORS côté backend.
- **404 SPA en prod** → assurez‑vous de `try_files $uri /index.html;` dans Nginx.

---

## Checklist de validation

- [ ] `http://localhost:5173` sert l’app avec HMR.
- [ ] `http://localhost:5173/api/ping` répond (proxy Vite → backend).
- [ ] Build `dist/` généré (`npm run build`).
- [ ] Image prod sert `index.html` et **proxy /api** fonctionne.
- [ ] Même contrat d’URL (`/api`) en dev & prod.

---

## Fichiers de référence (rappel)

- `frontend/Dockerfile` (multi‑étapes `dev` / `build` / `prod`)
- `frontend/vite.config.ts` (proxy dev `/api` → backend)
- `frontend/nginx.conf` (proxy prod `/api` → backend)
- `docker-compose.yml` (service `frontend` → target `dev`)

---

*Fin.*
