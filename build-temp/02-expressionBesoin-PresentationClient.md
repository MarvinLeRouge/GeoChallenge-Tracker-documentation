# 2. Expression du besoin et présentation client

## 2.1 Client principal

Avant de détailler les attentes précises, il est essentiel de présenter le public cible auquel l'application s'adresse.

Le géocaching est une chasse au trésor moderne qui utilise un GPS ou un smartphone pour localiser des contenants cachés (appelés "géocaches") dissimulés partout dans le monde par d'autres participants.

La communauté visée regroupe des géocacheurs passionnés qui voient dans les *challenges* un «&nbsp;jeu dans le jeu&nbsp;»&nbsp;: un niveau supplémentaire imposant des critères exigeants (difficulté/terrain, type, localisation, attributs) sur des périodes longues. Pour les plus investis, gérer ces contraintes devient un défi en soi. Les solutions existantes (ex. Project-GC premium) sont puissantes mais payantes. Sans outil adapté, le suivi relève d'une tâche chronophage avec risque d'erreurs.

GeoChallenge Tracker se positionne comme une solution accessible et intuitive, permettant à ces utilisateurs d'optimiser leur expérience sans multiplier les feuilles de calcul ou s'appuyer uniquement sur leur mémoire.

## 2.2 Attentes utilisateurs

De cette analyse des pratiques, ressortent plusieurs attentes fortes de la part des utilisateurs&nbsp;:

* un outil simple d'utilisation, mais puissant dans le traitement et le croisement de données,
* un suivi automatisé et visuel de leur progression,
* la possibilité d'identifier les caches qui permettent d'avancer sur plusieurs challenges à la fois,
* une cartographie efficace permettant de filtrer, de regrouper et de localiser les caches pertinentes,
* un respect strict de la confidentialité et de la sécurité de leurs données.

Afin de garantir que l'outil réponde réellement aux besoins, un **pool de testeurs expérimentés** est en cours de recrutement. Il inclut des géocacheurs aux profils variés&nbsp;:

* plusieurs joueurs, dont certains ayant trouvé **plus de 50 000 caches**, classés parmi les premiers au niveau national,
* des figures reconnues de la communauté (ex. membres actifs, auteurs, géocacheurs classés dans le top 5&nbsp;national),
* des profils diversifiés pour couvrir différents styles de jeu (grands voyageurs, spécialistes des caches T5, optimiseurs rationnels, etc.).

Ce panel permettra de confronter l'application à des pratiques intensives et variées, et de valider sa pertinence auprès de la communauté cible.

## 2.3 Personas

Pour mieux incarner ces attentes, plusieurs profils types (personas) permettent d'illustrer la diversité des besoins.

### Persona 1&nbsp;: le passionné des grands défis

**Âge**&nbsp;: 45 ans. **Profession**&nbsp;: Cadre supérieur. **Profil**&nbsp;: Géocacheur depuis plus de 15 ans, engagé dans des challenges de grande ampleur, impliquant plusieurs régions ou pays. Planifie ses voyages en fonction des caches à trouver. **Besoins**&nbsp;: Un suivi précis de l'avancement sur des objectifs étendus dans le temps et l'espace, avec des projections claires. Centralisation des données éparses provenant de multiples zones géographiques.

### Persona 2&nbsp;: la monitrice d'escalade

**Âge**&nbsp;: 34 ans. **Profession**&nbsp;: Monitrice d'escalade. **Profil**&nbsp;: Fan de caches T5, adore les défis nécessitant des compétences techniques en hauteur ou en spéléologie. Voyage souvent et recherche l'adrénaline. **Besoins**&nbsp;: Filtrer efficacement les caches selon les attributs extrêmes, voir rapidement ce qui reste à faire pour valider un challenge T5.

### Persona 3&nbsp;: l'optimisateur rationnel

**Âge**&nbsp;: 39 ans. **Profession**&nbsp;: Ingénieur en logistique. **Profil**&nbsp;: Participe à de nombreux challenges simultanément, mais privilégie l'efficacité. Cherche à réduire les déplacements inutiles en identifiant des caches qui permettent d'avancer sur plusieurs challenges à la fois. **Besoins**&nbsp;: Un outil capable de croiser les critères pour trouver les “caches multi-bénéfices”, et de calculer le meilleur compromis entre distance parcourue et progression réalisée.

## 2.4 Pool de testeurs

On peut retrouver l'ensemble des caractéristiques de ces personas en s'appuyant sur un panel de testeurs représentatifs de la communauté, constitué pour valider l'outil en conditions réelles. Il regroupe des géocacheurs aux profils variés, allant de joueurs passionnés à des figures reconnues du classement national. 
Ces retours permettent de confronter l'outil à des cas d'usage concrets et exigeants.

| Pseudo              | Caches trouvées | Caches posées | Rang national |
|---------------------|-----------------|---------------|---------------|
| **Almani06**        |          10 921 |            42 |             – |
| **Arnokovic**       |          86 909 |           303 |        4 (Fr) |
| **audeclar**        |           9 351 |           304 |             – |
| **falbala20220**    |          17 336 |           152 |      335 (Fr) |
| **Kidoulo**         |          10 932 |            96 |             – |
| **le sudiste**      |          35 203 |            46 | 70–75 (eq Fr) |
| **magiKache**       |           7 306 |           273 |             – |
| **MLRFamily**       |           6 279 |             7 |             – |
| **Orchidée83**      |           4 842 |             9 |             – |
| **oTo66**           |           4 382 |            89 |             – |
| **Phiphi13**        |          11 290 |           292 |             – |

Ce panel de testeurs apporte&nbsp;:

* la vision de **joueurs très expérimentés** (dont un classé **n°4 en France** en nombre de caches trouvées),
* l'expertise de **poseurs prolifiques**,
* et l'expérience de profils plus **familiaux ou intermédiaires**, garantissant une couverture diversifiée.

Ces retours permettent de vérifier à la fois la **pertinence fonctionnelle**, la **fiabilité technique** et l'**ergonomie** de l'outil.


## 2.5 Analyse de l'existant

**Project-GC** (seule alternative notable)&nbsp;:

- **Points forts**&nbsp;: Statistiques exhaustives, tableaux, gamification
- **Limites**&nbsp;: Interface dense, personnalisation limitée, pas de projection, accès premium requis, cartographie sans clustering d'où lecture difficile

## 2.6 Valeur ajoutée de GeoChallenge Tracker

- **Ergonomie mobile-first**&nbsp;: Cartes OSM, clustering, filtrage
- **Personnalisation**&nbsp;: Tâches définies par l'utilisateur (grammaire AST)
- **Projections temporelles**&nbsp;: Estimation de complétion
- **Gratuité**&nbsp;: Pas d'abonnement, APIs ouvertes

## 2.7 Objectifs fonctionnels

- **Import de données**&nbsp;: Parser GPX/ZIP multi-namespace
- **Gestion des challenges**&nbsp;: CRUD avec conditions AST
- **Suivi de progression**&nbsp;: Calculs temps réel et historique, représentation graphique intuitive 
- **Identification de cibles**&nbsp;: Algorithme d'optimisation, priorisation automatisée des candidats
- **Cartographie**&nbsp;: Visualisation interactive des caches, clustering pour faciliter la lecture de cartes
- **Itinérance**&nbsp;: Doit permettre un usage aisé sur mobile, y compris en situation d'itinérance

## 2.8 Objectifs techniques

- **Performance**&nbsp;: Temps de réponse < 200ms
- **Scalabilité**&nbsp;: Support de 100k+ caches par utilisateur
- **Sécurité**&nbsp;: Authentification JWT, validation stricte
- **Disponibilité**&nbsp;: 99.9% uptime
- **Compatibilité**&nbsp;: Mobile et desktop modernes
