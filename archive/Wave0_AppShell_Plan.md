# Vague 0 — AppShell & Auth (Plan court)

## Objectifs
- Squelette UI persistant (header + sidenav + `<router-view>` + toasts).
- Routing public/protégé + redirections.
- Auth de base (login, register, verify, resend) + refresh token automatique.
- Page d’accueil **dummy** pour valider l’ensemble.

---

## Arbo routes (min)
```
/              -> HomeDummy
/login         -> Login
/register      -> Register
/verify-email  -> VerifyEmail
/resend-verification -> ResendVerification
/(protected)   -> placeholder (redir /login si non auth)
/:pathMatch(.*)-> NotFound
```

---

## Fichiers (squelette)
```
src/
  app/AppShell.vue
  router/index.ts
  store/auth.ts
  api/http.ts            # axios instance + interceptors
  pages/
    HomeDummy.vue
    Login.vue
    Register.vue
    VerifyEmail.vue
    ResendVerification.vue
    NotFound.vue
  components/ui/Toaster.vue (ou plugin)
```

---

## Garde de route (algo)
1. Lire `auth.isAuthenticated` (store) + `auth.hasValidAccessToken()`.
2. Si route protégée et non auth → `next('/login')` (+ `redirect` query).
3. Si route auth-only (ex: /login) ET auth → `next('/')`.
4. Sinon `next()`.

---

## Intercepteur axios (refresh)
- **request**: ajouter `Authorization: Bearer <access>` si dispo.
- **response (401)**:
  1) tenter `POST /auth/refresh` avec refresh en mémoire.
  2) si OK → rejouer la requête.
  3) sinon → `logout()` + redirect `/login`.

> Stockage: access (mémoire) + refresh (storage). Timestamp pour refresh proactif facultatif.

---

## Tests rapides
- Accéder `/` → AppShell visible + liens.
- Accéder route protégée (placeholder) non connecté → redir `/login`.
- Se connecter (endpoint `/auth/login`) → retour à la route d’origine.
- Expirer access → un appel API → refresh → OK → pas de logout.
- 401 sur refresh → logout + redirect login.

---

## Commit & branche
- Branche: `frontend/auth` (merge → `frontend/main`).
- Commit:
```
feat(appshell): layout persistant + routing/guards + auth flow minimal
```

---

## Suivi (DoD)
- Guard OK (redir selon état).
- Intercepteur refresh OK (retry 1 fois).
- Pages auth minimalistes fonctionnelles.
- HomeDummy + NotFound présentes.
