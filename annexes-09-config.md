# 07. Configuration
## 07.1 Docker Compose
```yml
# ---------------------------
# docker-compose.yml
# ---------------------------
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
    environment:
      - MONGODB_USER=${MONGODB_USER}
      - MONGODB_PASSWORD=${MONGODB_PASSWORD}
      - MONGODB_URI_TPL=${MONGODB_URI_TPL}
      - MONGODB_DB=${MONGODB_DB}
      - JWT_SECRET_KEY=${JWT_SECRET_KEY}
      - SMTP_HOST=${SMTP_HOST}
      - SMTP_PORT=${SMTP_PORT}
    depends_on:
      - maildev
    volumes:
      - ./backend:/app
      - ./backend/uploads:/app/uploads
      - ./backend/data/samples:/app/data/samples
      - ./.env:/app/.env
    restart: unless-stopped

  maildev:
    container_name: geo-maildev
    image: maildev/maildev
    ports:
      - "1080:1080"
      - "1025:1025"
    restart: unless-stopped

  # --- Frontend unifié avec variable d'environnement ---
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
      target: ${DOCKER_TARGET:-dev}
      args:
        VITE_API_URL: ${VITE_API_URL:-/api}
        VITE_TILE_URL: ${VITE_TILE_URL:-/tiles/{z}/{x}/{y}.png}
    container_name: geo-frontend
    env_file:
      - .env
    environment:
      - CHOKIDAR_USEPOLLING=${CHOKIDAR_USEPOLLING:-true}
      - VITE_API_URL=${VITE_API_URL:-/api}
      - VITE_TILE_URL=${VITE_TILE_URL:-/tiles/{z}/{x}/{y}.png}
    depends_on:
      - backend
      - tiles
    ports:
      - "${FRONTEND_PORT:-5173}:${FRONTEND_INTERNAL_PORT:-5173}"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    restart: unless-stopped

  # --- Service tiles (commun dev/prod) ---
  tiles:
    image: nginx:1.25-alpine
    container_name: geo-tiles
    restart: unless-stopped
    command: |
      sh -c "
        rm -f /etc/nginx/conf.d/default.conf &&
        mkdir -p /var/log/nginx /var/cache/nginx/tiles_cache &&
        nginx -g 'daemon off;'
      "
    volumes:
      # Configuration optimisée
      - ./ops/nginx/tiles.conf:/etc/nginx/conf.d/tiles.conf:ro
      # Santé + assets locaux
      - ./ops/nginx/www:/var/www:ro
      # Cache persistant avec permissions
      - tiles_cache:/var/cache/nginx/tiles_cache
      # Logs pour debug
      - tiles_logs:/var/log/nginx
    ports:
      - "8080:80"
    # Limite mémoire pour éviter les fuites
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
    # Santé du conteneur
    healthcheck:
      test: ["CMD-SHELL", "wget -q -O /dev/null http://127.0.0.1/tiles/_health.png || exit 1"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 10s

volumes:
  tiles_cache:
    driver: local
  tiles_logs:
    driver: local

# --- Commandes rapides ---
# Développement: docker-compose --profile dev up -d
# Production:    docker-compose --profile prod up -d
# Les deux:      docker-compose --profile dev --profile prod up -d
```

## 07.2 Backend python
```
aiosmtplib==4.0.2
annotated-types==0.7.0
anyio==4.11.0
bcrypt==4.0.1
black==24.8.0
certifi==2025.8.3
charset-normalizer==3.4.3
click==8.3.0
coverage==7.10.7
dnspython==2.8.0
dotenv==0.9.9
ecdsa==0.19.1
email-validator==2.3.0
fastapi==0.117.1
h11==0.16.0
httpcore==1.0.9
httpx==0.28.1
idna==3.10
iniconfig==2.1.0
lxml==6.0.2
lxml-stubs==0.5.1
markdown-it-py==4.0.0
mdurl==0.1.2
mypy==1.14.1
mypy_extensions==1.1.0
packaging==25.0
passlib==1.7.4
pathspec==0.12.1
platformdirs==4.4.0
pluggy==1.6.0
pyasn1==0.6.1
pydantic==2.11.9
pydantic-settings==2.10.1
pydantic_core==2.33.2
Pygments==2.19.2
pymongo==4.15.1
pytest==8.3.5
pytest-cov==5.0.0
pytest-env==1.1.5
python-dotenv==1.1.1
python-jose==3.5.0
python-multipart==0.0.20
requests==2.32.5
rich==14.1.0
rsa==4.9.1
ruff==0.13.1
selectolax==0.3.34
six==1.17.0
sniffio==1.3.1
starlette==0.48.0
types-passlib==1.7.7.20250602
types-pyasn1==0.6.0.20250914
types-python-jose==3.5.0.20250531
typing-inspection==0.4.1
typing_extensions==4.15.0
urllib3==2.5.0
uvicorn==0.37.0
```

## 07.3 Frontend Vue.js
```json
{
  "name": "frontend",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "engines": {
    "node": ">=20 <=24"
  },
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "build:test": "vite build --mode test",
    "preview": "vite preview",
    "preview:test": "vite preview --mode test",
    "lint": "eslint . --ext .ts,.tsx,.vue --max-warnings=0",
    "typecheck": "vue-tsc --noEmit",
    "test:unit": "vitest run --coverage --config vitest.config.ts",
    "test:unit:watch": "vitest --config vitest.config.ts",
    "test:e2e": "npm run build:test && playwright test",
    "test:e2e:ui": "npm run build:test && playwright test --ui",
    "test:e2e:headed": "npm run build:test && playwright test --headed",
    "tests:all": "npm run lint && npm run typecheck && npm run test:unit && npm run test:e2e && npm run build"
  },
  "dependencies": {
    "@heroicons/vue": "^2.2.0",
    "axios": "^1.11.0",
    "flowbite": "^3.1.2",
    "flowbite-vue": "^0.2.1",
    "leaflet": "^1.9.4",
    "leaflet-draw": "^1.0.4",
    "leaflet.markercluster": "^1.5.3",
    "lucide-vue-next": "^0.542.0",
    "pinia": "^3.0.3",
    "tailwindcss": "^3.4.17",
    "vue": "^3.5.17",
    "vue-router": "^4.5.1",
    "vue-sonner": "^2.0.8"
  },
  "devDependencies": {
    "@eslint/js": "^9.36.0",
    "@playwright/test": "^1.55.1",
    "@types/dompurify": "^3.0.5",
    "@types/leaflet": "^1.9.20",
    "@types/leaflet.markercluster": "^1.5.6",
    "@types/node": "^24.3.0",
    "@typescript-eslint/eslint-plugin": "^8.44.1",
    "@typescript-eslint/parser": "^8.44.1",
    "@vitejs/plugin-vue": "^6.0.1",
    "@vitest/coverage-v8": "^3.2.4",
    "autoprefixer": "^10.4.21",
    "dompurify": "^3.2.7",
    "dotenv": "^17.2.2",
    "eslint": "^9.36.0",
    "eslint-plugin-vue": "^9.33.0",
    "globals": "^16.4.0",
    "jsdom": "^27.0.0",
    "playwright": "^1.47.0",
    "postcss": "^8.5.6",
    "typescript": "^5.9.2",
    "typescript-eslint": "^8.44.1",
    "vite": "^7.0.3",
    "vitest": "^3.2.4",
    "vue-eslint-parser": "^9.4.3",
    "vue-tsc": "^3.0.6"
  },
  "overrides": {
    "esbuild": "^0.25.2"
  }
}
```