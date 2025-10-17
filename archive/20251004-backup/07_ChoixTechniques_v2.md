# 7. Choix techniques

## 7.1 Backend

Le choix du backend s’est porté sur FastAPI, pour des raisons de rapidité, de sécurité et de simplicité d’intégration.

* **FastAPI (Python)** : choisi pour sa rapidité de développement, sa clarté syntaxique et son support natif d’OpenAPI.
* **Points forts** : asynchrone, validation avec Pydantic, gestion simple des dépendances.
* **Sécurité** : intégration native d’OAuth2, JWT, dépendances paramétrées pour gérer rôles et droits.

```python
# Validation de la complexité du mot de passe
def validate_password_strength(password: str) -> bool:
    """Valide la complexité du mot de passe (MIN_PASSWORD_LENGTH+ chars, A/a/0/special). Lève HTTP 400 sinon."""
    if len(password) < MIN_PASSWORD_LENGTH \
        or not re.search(r"[A-Z]", password) \
        or not re.search(r"[a-z]", password) \
        or not re.search(r"[0-9]", password) \
        or not re.search(r"[\W_]", password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Password must be at least {MIN_PASSWORD_LENGTH} characters and include uppercase, lowercase, number, and special character."
        )
    return True
```

```python
# Vérification du mot de passe (Passlib/bcrypt)
def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Compare le mot de passe en clair au hash stocké."""
    return pwd_context.verify(plain_password, hashed_password)
```

```python
# Création d’un access token JWT
def create_access_token(data: dict, expires_delta: dt.timedelta | None = None):
    """Encode un JWT signé avec 'exp' (par défaut +15 min si non précisé)."""
    to_encode = data.copy()
    expire = now() + (expires_delta or dt.timedelta(minutes=15))
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.jwt_secret_key, algorithm=settings.jwt_algorithm)
    return encoded_jwt
```

* **Exemple d’usage** : définition rapide des endpoints REST, testables automatiquement via `/docs`.

## 7.2 Frontend

Le frontend repose sur Vue.js 3, accompagné de bibliothèques spécialisées pour le style et la cartographie.

* **Vue.js 3** : framework progressif, adapté au rendu dynamique de données complexes.
* **Librairies** : Tailwind CSS pour le style rapide, Leaflet pour la cartographie interactive.
* **Optimisation** : clustering des marqueurs, tile caching pour réduire la charge réseau et améliorer la fluidité sur mobile.
* **Approche “green computing via performance optimizing”** : chaque interaction doit minimiser le rendu inutile, afin de préserver batterie et ressources CPU.

## 7.3 Base de données

Pour la persistance des données, le choix de MongoDB s’explique par la variabilité inhérente aux caches géocaching.

* **MongoDB (NoSQL)** : choisi pour sa souplesse documentaire. Les caches étant très hétérogènes (attributs variables, champs facultatifs), le modèle documentaire colle mieux que le relationnel.
* **Index** : `2dsphere` pour les recherches géospatiales, indexes uniques pour GC et utilisateurs, indexes combinés pour les filtres métiers (D/T, attributs).
* **Avantage** : structure flexible, évolutive selon l’apparition de nouveaux types de caches ou de challenges.

## 7.4 Intégrations externes

L’application s’appuie également sur des services externes, principalement des APIs OpenData.

* **APIs OpenData** : utilisées pour l’altimétrie et la localisation (communes).
* **Choix stratégique** : indépendance contractuelle (pas de dépendance propriétaire), souplesse (changement ou combinaison d’APIs si besoin), résilience (répartition de charge possible).
* **Mitigation des risques** : respect strict des quotas d’appel, stockage en base pour limiter la redondance des requêtes.

## 7.5 DevOps et qualité

Enfin, la démarche DevOps et les objectifs qualité viennent compléter l’architecture en assurant la robustesse et la maintenabilité du projet.

* **Docker / docker-compose** : reproductibilité entre environnements dev/prod.
* **CI/CD GitHub Actions** : linting, tests Pytest, build images, déploiement automatisé.
* **Tests** : Pytest (backend), Cypress (frontend).
* **Sécurité** : secrets gérés via variables d’environnement, pas en dur dans le code.
* **Observabilité** : logs structurés, métriques de performance prévues.

*En résumé :* Les choix techniques privilégient la **sécurité**, la **performance** (y compris mobile et éco-conception), et la **souplesse** pour s’adapter à la variabilité du geocaching et à l’évolution des APIs externes.
