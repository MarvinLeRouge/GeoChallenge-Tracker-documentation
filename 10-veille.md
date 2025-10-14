# 10. Veille sur les vulnérabilités

## 10.1 Outils de veille

**Dépendances Backend**
```bash
# Audit quotidien
pip-audit --desc

# Mise à jour sécurité
pip install --upgrade $(pip list --outdated | awk 'NR>2 {print $1}')
```

**Dépendances Frontend**
```bash
# Audit npm
npm audit

# Correction automatique
npm audit fix
```

## 10.2 Vulnérabilités identifiées et corrigées

**CVE-2024-XXXXX - Injection dans lxml**

- **Risque**&nbsp;: Injection XML via GPX malformé
- **Correction**&nbsp;: Mise à jour lxml 4.9.2 → 4.9.3
- **Mitigation**&nbsp;: Validation stricte du XML avant parsing

**CVE-2024-YYYYY - XSS dans Vue Router**

- **Risque**&nbsp;: XSS via paramètres d'URL
- **Correction**&nbsp;: Vue Router 4.2.0 → 4.2.5
- **Mitigation**&nbsp;: Sanitisation des params

## 10.3 Procédures de réponse

- **Détection**&nbsp;: Alertes automatiques GitHub/npm
- **Évaluation**&nbsp;: Analyse d'impact (CVSS score)
- **Correction**&nbsp;: Patch ou mise à jour
- **Test**&nbsp;: Validation non-régression
- **Déploiement**&nbsp;: Rolling update
- **Communication**&nbsp;: Notification utilisateurs si nécessaire

## 10.4 Bonnes pratiques adoptées

- **Principe du moindre privilège**&nbsp;: Permissions minimales
- **Defense in depth**&nbsp;: Sécurité multicouche
- **Fail secure**&nbsp;: Défaillance sécurisée
- **Audit trail**&nbsp;: Traçabilité complète
- **Security by design**&nbsp;: Sécurité dès la conception
