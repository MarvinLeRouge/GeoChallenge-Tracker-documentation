# 9. Gestion de projet

## 9.1 Introduction
Le projet a été mené seul dans le cadre de la formation CDA.  
Les outils utilisés : GitHub Project (roadmap/kanban), Git, commits, et l’appui d’un pool de testeurs.

## 9.2 Planning prévisionnel
Organisation en lots thématiques :

| Lot | Intitulé                  | Période prévue   |
|-----|---------------------------|------------------|
| 1   | Conception documents       | début juillet    |
| 2   | Environnement technique    | mi-juillet       |
| 3   | Conception graphisme       | août-septembre   |
| 4   | Backend (modèles & sécu)   | juillet-août     |
| 5   | Déploiement & packaging    | août-septembre   |
| 6   | Ciblage & progression      | fin août-sept.   |
| 7   | Clôture & livrables        | septembre        |

### Outils de planification
- **Vue Roadmap** : représentation temporelle, utile pour plan global mais abstraite.
- **Vue Kanban** : colonnes « À faire », « En cours », « Fait », plus intuitive et motivante.

![Vue Roadmap](./screenshots/github/project-roadmap.png)  

La vue **Roadmap** de GitHub Project permet de représenter les tâches dans une chronologie, avec des jalons et une répartition temporelle. Elle offre une vision d’ensemble intéressante pour situer chaque lot dans le temps, et pour visualiser la progression globale du projet. Toutefois, cette vue reste assez abstraite dans la pratique : les tâches sont alignées dans une frise, mais sans retour direct sur leur état réel d’avancement ni sur le travail concret restant à effectuer.

<!-- pagebreak -->

![Vue Kanban](./screenshots/github/project-kanban.png)

La vue **Kanban**, au contraire, repose sur un principe simple : faire passer les cartes d’une colonne à une autre, de “À faire” à “En cours” puis à “Fait”. Ce mode de gestion apporte une dynamique plus opérationnelle : il met l’accent sur les actions immédiates et sur la progression visible. Chaque déplacement de carte constitue un retour tangible et motivant, ce qui facilite le suivi au quotidien. Cette approche permet aussi de limiter la dispersion en mettant en avant les tâches encore bloquées dans “À faire” ou “En cours”.

*Analyse personnelle* : Dans le cadre de ce projet, mené avec un **timing serré**, la vue Kanban s’est imposée comme la plus efficace. Elle m’a permis de rester centré sur les actions concrètes, en visualisant en permanence ce qui était achevé et ce qui restait à entreprendre. Le changement de statut entre les colonnes m’a donné un cadre clair et motivant, plus adapté à un projet solo que la vue Roadmap. Cette dernière reste utile pour illustrer la planification initiale, mais le Kanban a constitué l’outil principal de suivi opérationnel.

Je suis également conscient que dans un contexte différent, avec une équipe plus large ou un rôle davantage orienté vers le **pilotage global**, la vue Roadmap aurait été plus pertinente. Elle permet en effet de suivre la cohérence d’ensemble, de contrôler les dépendances entre tâches et de vérifier que les livrables sont alignés avec les échéances prévues. Dans ce projet, mené en solitaire, cette dimension avait moins de sens immédiat. Néanmoins, dans un cadre collaboratif, l’usage de la Roadmap s’imposerait comme un outil de coordination complémentaire au Kanban.

En conclusion, la gestion de projet a reposé sur des outils simples mais adaptés, permettant de concilier planification initiale et suivi opérationnel. L’approche Kanban a favorisé l’efficacité dans un contexte individuel et contraint, tout en gardant à l’esprit que d’autres vues, comme la Roadmap, seraient à privilégier pour une coordination d’équipe à plus grande échelle.

<!-- pagebreak -->


## 9.3 Suivi réel (commits et branches)

La réalité a montré un fort pic d’activité en août.  
Les branches Git ont servi d’outil de suivi par fonctionnalité :

| Branche             | Fonction principale     | Rôle |
|---------------------|------------------------|------|
| backend/auth        | Authentification, JWT  | sécurité API |
| backend/caches      | Import GPX, BDD        | ingestion |
| backend/challenges  | AST des tâches         | logique métier |
| backend/progress    | Projections            | stats, courbes |
| backend/targets     | Suggestions            | objectifs |
| backend/tests       | Pytest                 | qualité |
| frontend/auth       | UI login/register      | ergonomie |
| frontend/appshell   | Layout général         | navigation |
| frontend/ui-found.  | Design system          | styles |
| frontend/home       | Page d’accueil         | point d’entrée |

**Politique de merge** :  
- branches de travail → `backend/main` ou `frontend/main`,  
- puis uniquement depuis ces branches d’intégration → `main`.

> **Lien avec le DevOps** — Chaque intégration dans `main` déclenche automatiquement le **pipeline CI/CD** décrit au chapitre 8, garantissant un cycle **code → build → déploiement** sans rupture.

## 9.4 Analyse des écarts
- Documentation et env technique réalisés en temps voulu.  
- Backend concentré sur août (80+ commits).  
- Frontend amorcé plus tardivement.  
- Finalisation (tests, doc, packaging) sur septembre.

## 9.5 Environnement humain
Un pool de testeurs variés (ex. **Arnokovic, n°4 français**, poseurs prolifiques, profils familiaux).  
Ils garantissent des retours pertinents et représentatifs.

## 9.6 Objectifs qualité
- **Logicielle** : Pytest, Cypress, CI/CD.  
- **Usage** : mobile-first, perf optimisée.  
- **Sécurité** : mots de passe forts, JWT, RGPD.  
- **Maintenabilité** : archi claire, indexes Mongo, seeding idempotent.
