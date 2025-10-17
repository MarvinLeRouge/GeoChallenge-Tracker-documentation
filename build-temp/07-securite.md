# 7. Sécurité de l'application
## 7.1 Authentification et autorisation

### 7.1.1 JWT avec refresh tokens
- Access token&nbsp;: 60 minutes
- Refresh token&nbsp;: 30 jours
- Rotation automatique des tokens
- Blacklist des tokens révoqués

### 7.1.2 Gestion des rôles
```python
# backend/app/core/security.py
def require_admin(current_user = Depends(get_current_user)):
    if current_user.role != "admin":
        raise HTTPException(403, "Admin access required")
    return current_user
```

## 7.2 Protection des données

### 7.2.1 Hashage des mots de passe
```python
# Bcrypt avec salt automatique
password_hash = bcrypt.hashpw(
    password.encode('utf-8'),
    bcrypt.gensalt(rounds=12)
)
```

### 7.2.2 Isolation par utilisateur
```python
# Toutes les requêtes filtrent par user_id
{"user_id": current_user.id}
```

## 7.3 Validation et sanitisation

### 7.3.1 Validation Pydantic stricte
```python
class CacheCreate(BaseModel):
    gc: str = Field(..., regex="^GC[A-Z0-9]{1,10}$")
    lat: float = Field(..., ge=-90, le=90)
    lon: float = Field(..., ge=-180, le=180)

    @validator('*', pre=True)
    def sanitize_strings(cls, v):
        if isinstance(v, str):
            return v.strip()[:1000]  # Limite et nettoie
        return v
```

### 7.3.2 Protection XSS
```python
# Sanitisation HTML
from bleach import clean

def sanitize_html(html: str) -> str:
    return clean(
        html,
        tags=['p', 'br', 'strong', 'em', 'a'],
        attributes={'a': ['href']},
        strip=True
    )
```

## 7.4 Protection contre les attaques

### 7.4.1 Rate limiting
- Global&nbsp;: 100 req/min par IP
- Auth&nbsp;: 5 tentatives/min
- Upload&nbsp;: 10 fichiers/heure

### 7.4.2 CSRF Protection
- SameSite cookies
- Origin validation
- Double submit tokens

### 7.4.3 SQL/NoSQL Injection
- Requêtes paramétrées uniquement
- Pas de construction dynamique
- Validation des ObjectId

## 7.5 Audit et monitoring

### 7.5.1 Logs de sécurité
```python
# Événements trackés
- Tentatives de connexion échouées
- Changements de permissions
- Accès aux données sensibles
- Uploads de fichiers
```

### 7.5.2 Métriques
- Taux d'erreurs 401/403
- Temps de réponse par endpoint
- Volume de données par utilisateur
