# 11. Veille — sécurité & technologies

Pendant le développement de *GeoChallenge Tracker*, une veille continue a été menée sur la sécurité et les technologies utilisées.  
Cette démarche s’est concentrée à la fois sur les vulnérabilités spécifiques à **FastAPI** et **MongoDB**, et sur des menaces plus larges liées aux **dépendances logicielles** (chaîne d’approvisionnement, packages compromis).  
L’objectif est double : anticiper les risques et garantir la robustesse du projet dans la durée.

---

## 11.1 Cas concrets récents

### 11.1.1 Compromission de paquets npm (attaque de la chaîne d’approvisionnement)
En septembre 2025, plusieurs paquets très utilisés sur **npm** (*debug*, *chalk*, *ansi-styles*) ont été compromis à la suite d’un compte mainteneur piraté via une attaque de phishing.  
Les versions infectées injectaient du code malveillant visant notamment le vol de fonds dans des portefeuilles crypto.  
Cet incident, considéré comme l’une des plus grosses attaques sur npm, illustre la **fragilité de la chaîne d’approvisionnement** : même des dépendances réputées sûres peuvent devenir un vecteur d’attaque.  
Cela rappelle l’importance d’un suivi attentif des versions et de ne dépendre que de packages essentiels【web†source】.

### 11.1.2 Vulnérabilité FastAPI Guard (CVE-2025-46814)
Une vulnérabilité a été identifiée dans la librairie *FastAPI Guard*, un middleware utilisé pour ajouter des contrôles de sécurité (restriction d’IP, logging, etc.) dans FastAPI.  
Elle permettait d’injecter une valeur dans l’en-tête `X-Forwarded-For` et de contourner certains contrôles d’accès basés sur l’adresse IP.  
Les journaux pouvaient être falsifiés et des clients non autorisés pouvaient passer pour des utilisateurs légitimes.  
Le problème a été corrigé rapidement, mais cet événement démontre qu’un projet ne doit pas se contenter des protections par défaut : il faut surveiller activement les **dépendances tierces** et limiter leur usage au strict nécessaire【web†source】.

### 11.1.3 Incident de sécurité MongoDB (décembre 2023)
En décembre 2023, MongoDB a révélé un incident de sécurité impliquant un accès non autorisé à ses systèmes internes après une campagne de phishing.  
Des métadonnées clients (noms, adresses e-mail, numéros de téléphone) ont été exposées, même si les données hébergées sur MongoDB Atlas n’ont pas été compromises.  
Cet épisode illustre que même les grands acteurs du cloud peuvent être vulnérables à des attaques ciblées, et qu’une vigilance accrue est nécessaire sur les **comptes administratifs** et les **mécanismes d’authentification**【web†source】.

---

## 11.2 Implications pour *GeoChallenge Tracker*

Ces événements démontrent que les menaces sont multiples et peuvent provenir aussi bien des **dépendances** que des **services managés**.  
Dans ce projet :  
- seules les dépendances strictement nécessaires sont retenues,  
- les versions des bibliothèques sont suivies et mises à jour régulièrement,  
- des bonnes pratiques de sécurité sont appliquées (validation stricte des entrées, séparation des rôles, tokens JWT avec durées distinctes, index sécurisés en base),  
- une attention particulière est portée à la configuration de MongoDB pour éviter tout accès non contrôlé.  

La veille se poursuivra dans la durée, notamment via le suivi des CVE concernant FastAPI, Starlette, MongoDB, ainsi que les bibliothèques Python utilisées dans le projet.

---

## 11.3 Sources

- [JFrog – Compromission de paquets npm (septembre 2025)](https://jfrog.com/blog/new-compromised-packages-in-largest-npm-attack-in-history/?utm_source=chatgpt.com)  
- [NVD – Vulnérabilité FastAPI Guard (CVE-2025-46814)](https://nvd.nist.gov/vuln/detail/CVE-2025-46814?utm_source=chatgpt.com)  
- [MongoDB – Incident de sécurité (décembre 2023)](https://www.mongodb.com/company/blog/news/mongodb-security-incident-update-december-20-2023?utm_source=chatgpt.com)  
- [Snyk – Vulnérabilités FastAPI](https://security.snyk.io/package/pip/fastapi?utm_source=chatgpt.com)  
- [Article Medium – Vulnérabilité critique Starlette / FastAPI](https://medium.com/%40onurbaskin/critical-security-vulnerability-in-starlette-fastapi-f75adfb86134?utm_source=chatgpt.com)  

**Chaîne YouTube recommandée** :  
- [Fireship – API Security in 100 Seconds](https://www.youtube.com/watch?v=7S_tz1z_5bA) (vidéo concise présentant les principaux risques et bonnes pratiques pour sécuriser des APIs modernes).  
