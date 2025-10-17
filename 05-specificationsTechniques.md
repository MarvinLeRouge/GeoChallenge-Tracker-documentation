# 5. Spécifications techniques

## 5.1 Backend

Le choix du backend s'est porté sur FastAPI, pour des raisons de rapidité, de sécurité et de simplicité d'intégration.

* **FastAPI (Python)**&nbsp;: choisi pour sa rapidité de développement, sa clarté syntaxique et son support natif d'OpenAPI.
* **Points forts**&nbsp;: asynchrone, validation avec Pydantic, gestion simple des dépendances.
* **Sécurité**&nbsp;: intégration native d'OAuth2, JWT, dépendances paramétrées pour gérer rôles et droits.

```python
# requirements.txt
fastapi==0.117.1
pydantic==2.11.9
pymongo==4.15.1
passlib[bcrypt]==1.7.4
lxml==6.0.2
httpx==0.28.1
...
```

## 5.2 Frontend

Le frontend repose sur Vue.js 3, accompagné de bibliothèques spécialisées pour le style et la cartographie.

* **Vue.js 3**&nbsp;: framework progressif, adapté au rendu dynamique de données complexes.
* **Librairies**&nbsp;: Tailwind CSS pour le style rapide, Leaflet pour la cartographie interactive.
* **Optimisation**&nbsp;: clustering des marqueurs, tile caching pour réduire la charge réseau et améliorer la fluidité sur mobile.
* **Approche “green computing via performance optimizing”**&nbsp;: chaque interaction doit minimiser le rendu inutile, afin de préserver batterie et ressources CPU.

```json
// package.json
{
  "dependencies": {
    "vue": "^3.5.17",
    "@vue/router": "^4.5.1",
    "pinia": "^3.0.3",
    "axios": "^1.11.0",
    "leaflet": "^1.9.9",
    "leaflet.markercluster": "^1.5.3"
  },
  "devDependencies": {
    "vitest": "^3.2.4",
    "@eslint/js": "^9.36.0",
    "@playwright/test": "^1.55.1",
  }
}
```

## 5.3 Base de données

Pour la persistance des données, le choix de MongoDB s'explique par la variabilité inhérente aux caches géocaching.

* **MongoDB (NoSQL)**&nbsp;: choisi pour sa souplesse documentaire. Les caches étant très hétérogènes (attributs variables, champs facultatifs), le modèle documentaire colle mieux que le relationnel.
* **Index**&nbsp;: `2dsphere` pour les recherches géospatiales, uniques pour GC et utilisateurs, combinés pour les filtres métiers (D/T, attributs).
* **Avantage**&nbsp;: structure flexible, évolutive selon l'apparition de nouveaux types de caches ou de challenges.

<!-- pagebreak -->
## 5.4 Infrastructure Docker

```yaml
# docker-compose.yml
services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: geo-backend
    ports:
      - "8000:8000"
    env_file:
      - .env
    volumes:
      - ./backend:/app
      - ./backend/uploads:/app/uploads
    restart: unless-stopped

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: geo-frontend
    env_file:
      - .env
    depends_on:
      - backend
      - tiles
    ports:
      - "${FRONTEND_PORT:-5173}:${FRONTEND_INTERNAL_PORT:-5173}"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    restart: unless-stopped

  tiles:
    image: nginx:1.25-alpine
    container_name: geo-tiles
    restart: unless-stopped
    command: |
      sh -c "..."
    volumes:
      - ./ops/nginx/tiles.conf:/etc/nginx/conf.d/tiles.conf:ro
      - ./ops/nginx/www:/var/www:ro
      - tiles_cache:/var/cache/nginx/tiles_cache
    ports:
      - "8080:80"
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
    healthcheck:
      test: ["CMD-SHELL", "..."]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 10s
```

<!-- pagebreak -->
## 5.5 Intégrations externes

L'application s'appuie également sur des services externes, principalement des APIs OpenData.

* **APIs OpenData**&nbsp;: utilisées pour l'altimétrie et la localisation (communes).
* **Choix stratégique**&nbsp;: indépendance contractuelle (pas de dépendance propriétaire), souplesse (changement ou combinaison d'APIs si besoin), résilience (répartition de charge possible).
* **Mitigation des risques**&nbsp;: respect strict des quotas d'appel, stockage en base pour limiter la redondance des requêtes.

## 5.6 Sécurité multicouche

### 5.6.1 Authentification JWT

Les tokens JWT permettent une authentification stateless sans session serveur, facilitant la scalabilité et l'intégration avec les SPA comme Vue.js.

```python
# backend/app/core/security.py
def create_access_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=60)
    to_encode.update({"exp": expire})
    return jwt.encode(
        to_encode,
        settings.JWT_SECRET_KEY,
        algorithm="HS256"
    )

def verify_token(token: str) -> dict:
    try:
        payload = jwt.decode(
            token,
            settings.JWT_SECRET_KEY,
            algorithms=["HS256"]
        )
        return payload
    except JWTError:
        raise HTTPException(401, "Invalid token")
```

### 5.6.2 Validation des entrées

La validation stricte des fichiers uploadés protège contre les injections de code malveillant, les vulnérabilités d'exécution et garantit l'intégrité des données.

```python
# backend/app/models/cache.py
class CacheBase(BaseModel):
    gc: str = Field(..., regex="^GC[A-Z0-9]+$")
    name: str = Field(..., min_length=1, max_length=255)
    difficulty: float = Field(..., ge=1.0, le=5.0)
    terrain: float = Field(..., ge=1.0, le=5.0)

    @validator('gc')
    def validate_gc_code(cls, v):
        if not v.startswith('GC'):
            raise ValueError('Invalid GC code')
        return v.upper()
```

<!-- pagebreak -->
### 5.6.3 Protection CORS

La configuration CORS empêche les requêtes non autorisées depuis des domaines externes et protège contre les attaques CSRF dans une architecture frontend/backend découplée.

```python
# backend/app/main.py
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### 5.6.4 Rate Limiting

Le rate limiting sur les appels à l'API OpenStreetMap respecte leur politique d'utilisation équitable, prévient les dépassements de quota et garantit la disponibilité du service pour tous les utilisateurs.

```nginx
# ops/nginx/tiles.conf
limit_req_zone $binary_remote_addr zone=tiles:10m rate=20r/s;

location /tiles/ {
    limit_req zone=tiles burst=50 nodelay;
    proxy_cache_valid 200 7d;
    proxy_cache tiles_cache;
}
```

## 5.7 Optimisations performance

### 5.7.1 Cache référentiels

L'ensemble des données statiques utilisent un système de cache.

```python
# backend/app/services/referentials_cache.py
class ReferentialsCache:
    def __init__(self):
        self._cache = {}
        self._last_refresh = None

    async def get_cache_types(self):
        if 'cache_types' not in self._cache:
            self._cache['cache_types'] = await db.cache_types.find().to_list()
        return self._cache['cache_types']

    def resolve_type_code(self, code: str) -> ObjectId:
        types = self._cache.get('cache_types', [])
        for t in types:
            if t['code'].lower() == code.lower():
                return t['_id']
        raise ValueError(f"Unknown type: {code}")

referentials = ReferentialsCache()
```

### 5.7.2 Agrégations MongoDB optimisées

Les pipelines d'agrégation MongoDB permettent d'effectuer les calculs et filtres directement côté base de données, réduisant le transfert de données et améliorant significativement les performances des requêtes complexes.

```python
# backend/app/services/progress.py
pipeline = [
    {"$match": {"user_id": user_id}},
    {"$lookup": {
        "from": "caches",
        "localField": "cache_id",
        "foreignField": "_id",
        "as": "cache"
    }},
    {"$unwind": "$cache"},
    {"$match": compiled_query},
    {"$group": {
        "_id": None,
        "count": {"$sum": 1},
        "sum_difficulty": {"$sum": "$cache.difficulty"}
    }}
]
```

### 5.7.3 Map tiles caching

Le cache des tuiles cartographiques réduit drastiquement les appels réseau vers les serveurs de tuiles, améliore les temps de chargement et diminue la charge sur les services tiers comme OSM ou Mapbox.

```
# User-Agent obligatoire avec contact
map $http_user_agent $osm_ua {
    "" "GCTracker/1.0 (+jean.ceugniet@gmail.com)";
    default "$http_user_agent GCTracker/1.0 (+jean.ceugniet@gmail.com)";
}

# ---- choose upstream host deterministically (a/b/c) ----
split_clients "${remote_addr}${request_uri}" $osm_server {
    33.3% "a.tile.openstreetmap.org";
    33.3% "b.tile.openstreetmap.org";
    *     "c.tile.openstreetmap.org";
}

# Bypass du cache si le client envoie "no-cache" ou "max-age=0"
map $http_cache_control $client_no_cache {
    default        0;
    ~*no-cache     1;
    ~*max-age=0    1;
}

# Rate limiting CLIENT → NOTRE SERVEUR (permissif pour UX)
limit_req_zone $binary_remote_addr zone=client_tiles:10m rate=20r/s;

# Rate limiting NOTRE SERVEUR → OSM (STRICT selon recommandations OSM)  
limit_req_zone $upstream_addr zone=osm_upstream:10m rate=2r/s;

# DNS resolver pour la résolution dynamique des noms OSM
resolver 127.0.0.11 valid=300s ipv6=off;
resolver_timeout 5s;

# Cache disque
proxy_cache_path /var/cache/nginx/tiles_cache
    levels=1:2
    keys_zone=tiles_cache:200m
    ...
        
server {
    listen 80;
    server_name _;

    # Logs détaillés
    access_log /var/log/nginx/tiles_access.log combined;
    error_log /var/log/nginx/tiles_error.log warn;

    # Santé rapide&nbsp;: http://host:8080/tiles/_health.png
    location = /tiles/_health.png {
        root /var/www;
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        ...
    }

    location /tiles/ {
        # Limite côté client (permet navigation fluide)
        limit_req zone=client_tiles burst=50 nodelay;
        
        # Limite vers OSM (STRICTE - respecte leurs guidelines)
        limit_req zone=osm_upstream burst=5 nodelay;

        # Validation format tiles
        if ($uri !~ "^/tiles/[0-9]{1,2}/[0-9]+/[0-9]+\.png$") {
            return 404;
        }

        # Validation zoom level (0-19 pour OSM)
        # retirer le préfixe /tiles/
        # PROXY VERS OSM
        proxy_pass https://$osm_server;

        # TLS/SNI
        proxy_ssl_server_name on;
        proxy_ssl_name $osm_server;
        proxy_ssl_protocols TLSv1.2 TLSv1.3;
        proxy_ssl_verify off;

        # Headers OSM requis
        proxy_set_header Host tile.openstreetmap.org;
        proxy_set_header User-Agent $osm_ua;
        ...

        # Utilise HTTP/1.1 côté upstream + pas de Connection: keep-alive explicite
        proxy_http_version 1.1;
        proxy_set_header Connection "";

        # Neutralise la compression (évite variations CDN)

        # --- CACHE ---
        proxy_cache tiles_cache;
        proxy_cache_key $scheme$proxy_host$request_uri;
        proxy_cache_bypass $client_no_cache;

        # Respect de la fraîcheur amont
        proxy_cache_revalidate on;
        proxy_pass_header Cache-Control;
        ...

        # Durées de cache selon OSM
        proxy_cache_valid 200 304 7d;    # tiles valides: 7 jours
        proxy_cache_valid 404 1m;        # tiles manquantes: 1 minute
        ...

        # Eviter les avalanches
        ...

        # Servir du stale si souci amont
        proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
        proxy_cache_background_update on;

        # Timeouts adaptés
        proxy_connect_timeout 10s;
        proxy_send_timeout 15s;
        proxy_read_timeout 30s;
        ...

        # Headers debug
        ...
        # Cache côté client (respecte les recommandations OSM)
        ...
        # Sécurité
        add_header X-Content-Type-Options "nosniff" always;

        # pas de cookies
    }

    # Bloquer toutes les autres requêtes
    location / {
        return 404;
    }
}
```