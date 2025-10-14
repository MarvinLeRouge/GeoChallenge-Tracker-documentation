# Diapo 1 — Titre
- **Logo / Projet / Date**  
	- Donne l’identité produit immédiatement (mémoire visuelle du jury).  
	- Situe le contexte (soutenance, jalon), cadre professionnel clair.  

---

# Diapo 2 — Présentation entreprise / client
- **Communauté géocaching**  
	- 7M géocacheurs dans le monde => Marché réel, besoins spécifiques (suivi challenges).  
	- Données terrain disponibles (GPX, OSM) => solution pragmatique.  
- **Client = passionnés de challenges**  
	- Segment exigeant => valeur d’usage forte.  
	- Adoption par effet de réseau (clubs, forums).  
- **Pool de testeurs**  
	- Retours qualifiés (100k+ trouvailles cumulées) => exigences haut niveau.  
	- Validation par l’usage réel => risque réduit, (in)validation rapide d'hypothèses

---

# Diapo 3 — Besoins / Contraintes / Livrables
- **Problème outils existants**  
	- UX dense, paywalls => opportunité de différenciation.  
	- Cible “mobile-first” souvent négligée.  
    - Mobile-first => opportunité de fonctionnalités utilisables sur le terrain.
- **Besoin : ergonomie + fonctionnalités + performance**  
	- Réduction charge cognitive => adoption rapide, car solution actuelle lourde et compliquée.  
	- Fonctions orientées résultat (projections, cibles).  
	- Objectif : performance < 2s => crédibilité technique et sobriété.  
- **Contraintes**  
	- Deadline stricte => priorisation (MoSCoW).  
	- Mobile-first => usage terrain, batterie, réseau limité.  
	- Respect rate limits => conformité fournisseurs, usage responsable.  
	- Plateforme test => boucle de feedback rapide.  
- **Livrables**  
	- Dossier projet + annexes : traçabilité des choix.
	- Documentation technique : transférabilité / maintenabilité..  
	- Application web fonctionnelle : valeur démontrable, et tests réalistes.

---

# Diapo 4 — Gestion de projet
- **Agile solo (10 sprints d’une semaine)**  
	- Cadence courte => visibilité, ajustements rapides, et garantie rendu minimal fonctionnel.  
	- Rétros hebdo => amélioration continue.
- **Suivi GitHub Projects**  
	- Transparence, traçabilité décisions.  
	- Intégration CI/CD => qualité continue.
    - Intégration CC => information continue des testeurs => maintien implication pool testeurs.
- **Stack technique**  
	- Docker / FastAPI / Vue.js : Standard moderne, écosystèmes matures.
    - Déploiements reproductibles, onboarding simple.
	- Environnements isolés => stabilité et portabilité.
- **Objectifs qualité**  
	- Tests et objectif coverage > 70 %.  
	- Objectif P95 < 2s => confort utilisateur et démarche green. Objectif évolutif à la baisse.
    - Green by design

---

# Diapo 5 — Architecture logicielle
- **3 tiers (Vue.js / FastAPI / MongoDB)**  
	- Séparation claire : présentation / métier / données => maintenance et évolution facilitées.  
	- Scalabilité horizontale simple (stateless API).  

- **Séparation routes / services / modèles**  
    - Testabilité (mocks sur services).
	- Code lisible et testable.  
	- Contrats de données explicites (schémas Pydantic).  
- **Encapsulation des dépendances externes (adapters légers)**  
	- Providers/parsers isolent les services externes.  
    - Anticipe d'éventuels futurs changements de providers de données externes.
	- Découplage progressif vers une approche hexagonale.  

---

# Diapo 6 — Maquettes & enchaînement
- **Screens (Accueil / Carte / Liste)**  
	- Parcours utilisateur clair, démonstration fluide.  
	- MVP centré sur la valeur fonctionnelle.  
- **Charte mobile-first sobre**  
	- Lisibilité, accessibilité, vitesse.
	- Impact environnemental réduit.
    - Une transition éventuelle mobile => desktop sera toujours beaucoup plus simple (moins de contraintes).

---

# Diapo 7 — Modèle de données
- **Modèle E/A simplifié**  
	- Communication claire entre techniques et métier.  
	- Moins de complexité => plus de robustesse.  
- **Index 2dsphere**  
	- Requêtes spatiales rapides (near/within).  
	- Garantit fluidité de la carte (UX + sobriété).  
- **Collections clés**  
	- Alignement direct avec cas d’usage (progress, tasks).  
	- Dénormalisation maîtrisée pour l’historique.  

---

# Diapo 8 — Cas d’utilisation
- **Importer GPX => gérer challenges => suivre progression**  
	- Enchaînement logique et centré utilisateur.  
	- Couvre tout le cycle fonctionnel.  

---

# Diapo 9 — Séquence : calcul de progression
- **Évaluation des tâches et agrégats**  
	- Données mesurables => indicateurs utiles.
	- Extensible à d’autres métriques (altitude, D/T).
    - La séparation de mesure des tâches permet d'anticiper un éventuel futur facteur de pondération.
- **Snapshots et séries temporelles**  
	- Suivi historique et projections futures.  
	- Lecture rapide, calculs déportés.  

---

# Diapo 10 — Interface : carte interactive
- **Leaflet + clustering + tile caching**  
	- Performant et open source.  
	- Lecture visuelle facilitée sur zones denses.  
- **Performance & green IT**  
	- Cache tuiles = bande passante réduite.  
	- Requêtes limitées => respect serveurs OSM => diminution risque blacklistage.  

---

# Diapo 11 — Interface : liste challenges
- **Filtrage / pagination / statuts**  
	- Réactivité même sur gros volumes.  
	- Clarté statuts => meilleure gestion utilisateur.  
- **Vue + Pinia**  
	- État centralisé, prévisible.  
	- Tests ciblés et maintenance aisée.  

---

# Diapo 12 — Interface : détails challenge
- **Sanitisation (DOMPurify)**  
	- Prévention XSS => sécurité front.  
	- Respect bonnes pratiques OWASP.
    - Adaptabilité contenu HTML au notre.
- **Notes & override**  
	- Transparence décisions manuelles.  
	- Traçabilité pour maintenance.  

---

# Diapo 13 — Composant métier : Parser GPX
- **Support multi-namespaces**  
	- Interopérabilité (cgeo, GSAK, groundspeak).  
	- Robustesse des imports.  
    - Anticipation des formats variables selon les sources.
- **Validation stricte**  
	- Données propres, sûres.  
	- Moins d’erreurs cascade.  

---

# Diapo 14 — Composant métier : moteur AST
- **Grammaire déclarative**  
	- Évolution sans refactor lourd.  
	- Règles auditées et traçables.  
- **Compilation => requêtes MongoDB**  
	- Exécution rapide (optimisée DB).  
	- Un seul langage : moins de complexité.  

---

# Diapo 15 — Accès données : recherche géospatiale
- **$geoNear + 2dsphere**  
	- Requêtes log-scalables.  
	- Ordre par distance = valeur immédiate.  
- **Agrégation + projection compacte**  
	- Latence faible, transfert réduit.  
	- Respect confidentialité (données minimales).  

---

# Diapo 16 — Accès données : calcul progression
- **evaluate_progress()**  
	- Centralise la logique, cohérence globale.  
	- MAJ atomiques des statuts => fiabilité.  
- **Snapshots**  
	- Historisation native pour graphiques.  
	- Lecture rapide sans recalcul. 
    - Économie calcul. 

---

# Diapo 17 — Provider altimétrie
- **Quotas / rate limiting**  
	- Respect des fournisseurs externes.  
	- Stabilité du service.  
- **Batch et tolérance erreurs**  
	- Résilience réseau.  
	- Expérience utilisateur continue. 
- **Abstraction service**
    - Évolutivité, possibilité de distribution des requêtes données externes entre différents providers.

---

# Diapo 18 — Sécurité : authentification
- **JWT + refresh tokens**  
	- Scalabilité (stateless).  
	- Rotation automatique => sûreté.  
- **Rôles (user/admin)**  
	- Principe du moindre privilège.  
	- Gestion simple et auditable.  

---

# Diapo 19 — Sécurité : protection multicouche
- **Validation Pydantic stricte**  
	- Entrées contrôlées, fail fast.  
	- Réduction surface d’attaque.  
- **Sanitisation, CORS, rate limiting**  
	- Défense XSS/CORS.  
	- Protection OSM => usage éthique.  
- **Isolation par utilisateur**  
	- Cloisonnement RGPD-friendly.  
	- Aucune fuite inter-profils.  

---

# Diapo 20 — Plan de tests
- **Pyramide 80/15/5**  
	- Bon équilibre coût/valeur.  
	- Régressions détectées tôt.  
- **Outils : Pytest / Vitest / Playwright**  
	- Couverture multi-couches.  
	- Automatisation CI.  
- **Objectif coverage > 70 %**  
	- Indicateur maturité.  
	- Réassurance jury qualité.  

---

# Diapo 21 — Jeu d’essai
- **5 fichiers GPX (attendus vs obtenus)**  
	- Validation end-to-end.  
	- Cas limites documentés.  
- **Pays / Régions / Challenges**  
	- Détection création vs existants.  
	- Import massif sans duplication. 
- **Idempotence**
    - Garantit la non-duplication des données
    - Protège des problèmes en cas de crash en cours de traitement

---

# Diapo 22 — Veille vulnérabilités
- **pip-audit / npm audit**  
	- Surveillance dépendances continue.  
	- Réduction risque 0-day.  
- **Procédure réponse CVE**  
	- Chaîne claire : détection => patch => test.  
	- Démarche proactive.  
- **Defense in depth / fail secure**  
	- Priorité sécurité dès la conception.  
	- Fiabilité > patchs ponctuels.  

---

# Diapo 23 — Conclusion
- **Compétences CDA couvertes**  
	- Vision bout-en-bout (frontend => DevOps).  
	- Cohérence projet / certification.  
- **Difficultés & solutions**  
	- Parsing GPX, perf Mongo, quotas OSM maîtrisés.  
	- Réactivité et pragmatisme.  
- **Perspectives**  
	- Mode offline, app mobile, IA ciblage.  
	- Montée en maturité produit.  

---

# Diapo 24 — Merci / Questions
- **Logo + rappel projet**  
	- Clôture visuelle cohérente.  
	- Transition naturelle vers les échanges.  
