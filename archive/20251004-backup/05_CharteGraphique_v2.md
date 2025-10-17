# 5. Charte graphique

Dans la conception de l’interface, une approche **mobile first** a été privilégiée.  
Ce choix repose sur plusieurs arguments. Tout d’abord, le mobile first conduit naturellement à une interface centrée sur le **contenu** et une **ergonomie simple et efficace**, ce qui correspond à l’objectif du projet. Cette orientation a été pensée en opposition à certains outils existants, comme *Project-GC*, dont le contenu est riche mais présenté de manière très dense : abondance de tableaux, polices réduites, couleurs juxtaposées dans de petites cases. Le résultat est puissant mais peu lisible sur mobile, et difficilement exploitable en situation de mobilité.  

Ensuite, l’application est amenée à être utilisée en **itinérance**, notamment pour la consultation cartographique lors de déplacements. Une ergonomie pensée pour le bureau (desktop) n’aurait donc pas été adaptée. Au contraire, l’interface mobile first assure une **utilisation fluide en contexte de terrain**, tout en restant **parfaitement utilisable sur desktop**. De plus, il est toujours plus aisé d’ajouter des **media queries** pour enrichir l’expérience sur grand écran que de tenter de linéariser une interface multi-colonnes afin de la rendre utilisable sur smartphone.  

Le design graphique repose volontairement sur une base **sobre et lisible**. Les polices choisies sont exclusivement **sans-serif**, le contraste entre texte et arrière-plan est maximal, et des nuances de gris ainsi que des variations de taille viennent hiérarchiser certains éléments. Ce travail permet une lecture confortable dans la majorité des situations. Une **passe d’accessibilité dédiée** pourra être envisagée dans une version ultérieure, afin de prendre en compte des besoins spécifiques (daltonisme, contrastes renforcés, lecteurs d’écran, etc.).  

La **navigation** a été conçue pour optimiser l’espace : des **menus dépliants** permettent de libérer la surface utile, tandis que des **icônes thématiques par section** facilitent le repérage et la mémorisation visuelle des fonctionnalités. Cet équilibre entre sobriété et guidage visuel constitue un gage d’ergonomie pour des utilisateurs variés, du joueur occasionnel au géocacheur expérimenté.  

Enfin, le **design épuré** retenu a aussi une incidence sur les performances. Il limite le nombre d’éléments graphiques et réduit donc les **temps de chargement**, la **bande passante consommée**, et même le **temps de mise en page (layout)** dans le navigateur. Cela correspond à une démarche naturellement plus efficiente sur le plan environnemental : un premier pas vers le **green IT**. Si la gestion efficace de la cartographie (notamment via le **tile caching**) constitue déjà un levier important, d’autres pistes d’optimisation (caching applicatif, traitement côté client mieux maîtrisé) pourront être explorées dans la suite du projet. Le design évite aussi toute lourdeur inutile : **aucune image lourde** n’est utilisée et les animations sont réduites au strict minimum.  

Le **nom** et le **logo** de l’application ont fait l’objet d’une réflexion spécifique. Le nom *GeoChallenge Tracker* exprime de manière explicite l’objectif du logiciel : aider l’utilisateur à suivre sa progression dans des challenges géocaching. Il se simplifie facilement en *GC Tracker*, une abréviation à la fois courte et parlante. L’acronyme *GC* résonne immédiatement auprès de la communauté, puisqu’il est déjà largement utilisé pour désigner *geocaching* ou *geocache*.  

Le logo reprend la base d’un **marqueur de position**, symbole universel de la géolocalisation, afin de rappeler immédiatement le contexte de l’activité. Plusieurs alternatives avaient été envisagées (escalier stylisé, coupe sportive, médaille, badge, ou encore dégradé de couleur), mais elles ont été écartées : trop complexes pour rester lisibles à petite taille, ou trop voyantes pour conserver une interface sobre. La solution finalement retenue repose sur un **histogramme intégré dans le marqueur**, exprimant à la fois la **notion de progression** et celle de **succès**. Les trois barres colorées montantes (rouge → jaune → vert) traduisent visuellement plusieurs idées : le **changement de statut** (échec → progression → réussite), l’**augmentation du taux de réalisation**, et la symbolique d’un **escalier**, associée à l’idée d’avancement et d’accomplissement. L’usage des couleurs s’appuie sur des codes universels, proches de ceux des feux de circulation ou des indicateurs sportifs, ce qui renforce l’immédiateté de la compréhension.  

Ainsi, l’ensemble des choix graphiques répond à un double objectif : proposer une **interface claire et efficace en mobilité**, tout en véhiculant une **identité visuelle forte** qui parle directement à la communauté geocaching.  

<!-- pagebreak -->

## 5.1 État non loggé

![Accueil+Menu non loggé](./screenshots/figma/homepage-menu-not-logged.png)

L’écran d’accueil, accessible sans connexion, sert avant tout de **teaser pour les géocacheurs**. 
Le haut de page met en avant la **simplicité du logiciel**, sa capacité à **remplacer avantageusement l’existant**, ainsi que son caractère **interactif** et l'intérêt de sa **cartographie**.
Le menu haut propose immédiatement les **actions essentielles** : créer un compte, se connecter, ou commencer.
Le contenu principal illustre les **étapes d’utilisation typiques**, avec une explication succincte de chaque phase.
Enfin, le **menu, volontairement réduit**, ne contient que les liens connexion / inscription, ainsi que les *mentions légales*, qui doivent rester *disponibles en toutes circonstances*.

<!-- pagebreak -->

## 5.2 Register / Login

![ Register / Login ](./screenshots/figma/register-login.png)

Les écrans d’inscription et de connexion suivent volontairement une **approche minimaliste**. Leur objectif est d’aller droit au but, conformément aux bonnes pratiques du domaine. 
Le formulaire d’inscription demande une confirmation du mot de passe, afin de **réduire les risques d’erreur** et d’**éviter la frustration** liée à un premier échec de connexion. 
La **sobriété visuelle** met en avant la **lisibilité** et la **fluidité** du parcours utilisateur.

<!-- pagebreak -->

## 5.3 État loggé (partie 1)

![ Accueil + Menu loggé ](./screenshots/figma/homepage-menu-logged.png)

<!-- pagebreak -->

## 5.4 Page d'accueil - Contenu complet

![ Accueil loggé - Contenu complet ](./screenshots/figma/homepage-logged-full-split.png)

La page d’accueil en version complète met en avant une **vision panoramique des fonctionnalités** disponibles. Le design conserve une structure claire, tout en affichant davantage d’éléments contextualisés pour l’utilisateur connecté. 
L’objectif est de fournir une **vue globale** qui associe lisibilité et exhaustivité, sans surcharger visuellement la page. Cette maquette met en lumière la **progression naturelle du parcours utilisateur**, depuis l’accès invité jusqu’à l’exploration complète des fonctionnalités. 

En conclusion, la conception graphique de GeoChallenge Tracker illustre une démarche pragmatique : partir des besoins des utilisateurs, proposer une interface simple et claire, et s’assurer que l’expérience reste fluide sur mobile comme sur desktop. L’usage de maquettes Figma a permis de matérialiser ces choix très tôt, en validant les parcours essentiels sans chercher à couvrir exhaustivement toutes les pages de l’application.  

Cette sobriété va de pair avec une réflexion sur les performances et l’impact environnemental. Dans une logique de **green IT**, toutes les ressources graphiques ont été optimisées, depuis les maquettes elles-mêmes jusqu’au logo en SVG, afin de réduire la taille des fichiers et d’accélérer leur affichage. L’ensemble contribue à un rendu plus léger et donc plus respectueux des contraintes de bande passante et de consommation.  

Ces choix traduisent une volonté de concilier **ergonomie, efficacité et responsabilité**, en offrant à la communauté des géocacheurs un outil accessible, lisible et durable, conçu dès l’origine avec une attention particulière portée à la simplicité et à la performance.

L'ensemble du prototype est consultable en ligne, [sur Figma](https://www.figma.com/proto/ba8qCI2QTFiJi3dkZAghaZ/Geocaching?node-id=0-1&t=09PPhu9lbqOrJfQR-1).
