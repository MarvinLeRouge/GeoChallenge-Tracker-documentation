# 5. Composants d'accès aux données

## 5.1 Modèle conceptuel de données

```mermaid
erDiagram
    USER ||--o{ USER_CHALLENGE : "participe"
    USER ||--o{ FOUND_CACHE : "trouve"
    USER ||--o{ TARGET : "vise"
    
    CACHE ||--o{ FOUND_CACHE : "est trouvée"
    CACHE ||--|| CHALLENGE : "définit"
    CACHE ||--o{ TARGET : "correspond"
    CACHE }o--|| CACHE_TYPE : "classée"
    CACHE }o--|| CACHE_SIZE : "dimensionnée"
    CACHE }o--|| COUNTRY : "située"
    CACHE }o--o| STATE : "située"
    CACHE }o--o{ CACHE_ATTRIBUTE : "possède"
    
    CHALLENGE ||--o{ USER_CHALLENGE : "assigné"
    
    USER_CHALLENGE ||--o{ USER_CHALLENGE_TASK : "décomposé"
    USER_CHALLENGE ||--o{ PROGRESS : "historisé"
    USER_CHALLENGE ||--o{ TARGET : "génère"
    
    COUNTRY ||--o{ STATE : "contient"
    
    USER_CHALLENGE_TASK ||--o{ TARGET : "satisfaite"
    
    USER {
        identifiant id
        texte username
        email email
        texte role
        booleen is_active
        booleen is_verified
        coordonnees location
        structure preferences
        horodatage created_at
        horodatage updated_at
    }
    
    CACHE {
        identifiant id
        code GC
        texte title
        texte_riche description_html
        url url
        coordonnees position
        entier elevation
        decimal difficulty
        decimal terrain
        ensemble attributes
        horodatage placed_at
        texte owner
        entier favorites
        statut status
        horodatage created_at
        horodatage updated_at
    }
    
    CACHE_TYPE {
        identifiant id
        texte name
        code code
        liste aliases
        horodatage created_at
        horodatage updated_at
    }
    
    CACHE_SIZE {
        identifiant id
        texte name
        code code
        entier order
        horodatage created_at
        horodatage updated_at
    }
    
    CACHE_ATTRIBUTE {
        identifiant id
        entier cache_attribute_id
        code txt
        texte name
        texte name_reverse
        liste aliases
        horodatage created_at
        horodatage updated_at
    }
    
    COUNTRY {
        identifiant id
        texte name
        code code
        horodatage created_at
        horodatage updated_at
    }
    
    STATE {
        identifiant id
        texte name
        code code
        horodatage created_at
        horodatage updated_at
    }
    
    FOUND_CACHE {
        identifiant id
        date found_date
        texte notes
        horodatage created_at
        horodatage updated_at
    }
    
    CHALLENGE {
        identifiant id
        texte name
        texte description
        structure meta
        horodatage created_at
        horodatage updated_at
    }
    
    USER_CHALLENGE {
        identifiant id
        statut status
        statut computed_status
        booleen manual_override
        texte override_reason
        horodatage overridden_at
        formule logic
        texte notes
        horodatage estimated_completion_at
        horodatage created_at
        horodatage updated_at
    }
    
    USER_CHALLENGE_TASK {
        identifiant id
        entier order
        texte title
        arbre_syntaxique expression
        structure constraints
        statut status
        horodatage start_found_at
        horodatage completed_at
        horodatage last_evaluated_at
        horodatage created_at
        horodatage updated_at
    }
    
    PROGRESS {
        identifiant id
        horodatage checked_at
        texte message
        texte engine_version
        horodatage created_at
    }
    
    TARGET {
        identifiant id
        decimal score
        liste reasons
        booleen pinned
        coordonnees loc
        structure diagnostics
        horodatage created_at
        horodatage updated_at
    }
```
<!-- pagebreak -->
## 5.2 Modèle physique de données

```mermaid
erDiagram
    users ||--o{ user_challenges : "user_id"
    users ||--o{ found_caches : "user_id"
    users ||--o{ targets : "user_id"
    
    caches ||--o{ found_caches : "cache_id"
    caches ||--o{ challenges : "cache_id"
    caches ||--o{ targets : "cache_id"
    caches }o--|| cache_types : "type_id"
    caches }o--|| cache_sizes : "size_id"
    caches }o--|| countries : "country_id"
    caches }o--o| states : "state_id"
    
    challenges ||--o{ user_challenges : "challenge_id"
    
    user_challenges ||--o{ user_challenge_tasks : "user_challenge_id"
    user_challenges ||--o{ progress : "user_challenge_id"
    user_challenges ||--o{ targets : "user_challenge_id"
    
    countries ||--o{ states : "country_id"
    
    user_challenge_tasks ||--o{ targets : "primary_task_id"
    
    users {
        ObjectId _id PK "unique"
        string username "unique, index"
        string email "unique, index"
        string role "enum:user,admin"
        bool is_active "default:true"
        bool is_verified "default:false"
        Point location "2dsphere index, {type:Point, coordinates:[lon,lat]}"
        object preferences "{language:string, dark_mode:bool}"
        ObjectId[] challenges "deprecated, computed from user_challenges"
        string verification_code
        ISODate verification_expires_at
        ISODate created_at
        ISODate updated_at
    }
    
    caches {
        ObjectId _id PK
        string GC "unique, index"
        string title
        string description_html "HTML blob"
        string url
        ObjectId type_id "index, FK→cache_types._id"
        ObjectId size_id "index, FK→cache_sizes._id"
        ObjectId country_id "index, FK→countries._id"
        ObjectId state_id "index, FK→states._id"
        double lat "decimal degrees"
        double lon "decimal degrees"
        Point loc "2dsphere index, {type:Point, coordinates:[lon,lat]}"
        int elevation "meters"
        object location_more "free-form: {city, department, ...}"
        double difficulty "1.0-5.0, index"
        double terrain "1.0-5.0, index"
        array attributes "[{attribute_doc_id:ObjectId, is_positive:bool}]"
        ISODate placed_at "index"
        string owner
        int favorites
        string status "enum:active,disabled,archived"
        ISODate created_at
        ISODate updated_at
    }
    
    cache_types {
        ObjectId _id PK
        string name "index"
        string code
        string[] aliases
        ISODate created_at
        ISODate updated_at
    }
    
    cache_sizes {
        ObjectId _id PK
        string name "index"
        string code
        int order "sort order"
        ISODate created_at
        ISODate updated_at
    }
    
    cache_attributes {
        ObjectId _id PK
        int cache_attribute_id "unique, global ID"
        string txt "unique, index, e.g. dogs_allowed"
        string name "e.g. Dogs allowed"
        string name_reverse "e.g. No dogs allowed"
        string[] aliases
        ISODate created_at
        ISODate updated_at
    }
    
    countries {
        ObjectId _id PK
        string name "unique, index"
        string code "ISO 3166-1 alpha-2"
        ISODate created_at
        ISODate updated_at
    }
    
    states {
        ObjectId _id PK
        string name "compound index (country_id, name)"
        string code
        ObjectId country_id "FK→countries._id, compound index"
        ISODate created_at
        ISODate updated_at
    }
    
    found_caches {
        ObjectId _id PK
        ObjectId user_id "compound unique (user_id, cache_id)"
        ObjectId cache_id "compound unique (user_id, cache_id)"
        ISODate found_date "date only, index"
        string notes
        ISODate created_at
        ISODate updated_at
    }
    
    challenges {
        ObjectId _id PK
        ObjectId cache_id "unique, FK→caches._id"
        string name
        string description
        object meta "{avg_days_to_complete:double, avg_caches_involved:double, completions:int, acceptance_rate:double}"
        ISODate created_at
        ISODate updated_at
    }
    
    user_challenges {
        ObjectId _id PK
        ObjectId user_id "compound unique (user_id, challenge_id)"
        ObjectId challenge_id "compound unique (user_id, challenge_id)"
        string status "enum:pending,accepted,dismissed,completed, index"
        string computed_status "enum:pending,accepted,dismissed,completed, calculated"
        bool manual_override "default:false"
        string override_reason
        ISODate overridden_at
        object logic "AST: {kind:and|or|not, task_ids:ObjectId[]}"
        object progress "DENORM: {percent:double, tasks_done:int, tasks_total:int, checked_at:ISODate}"
        string notes
        ISODate estimated_completion_at
        ISODate created_at "index"
        ISODate updated_at
    }
    
    user_challenge_tasks {
        ObjectId _id PK
        ObjectId user_challenge_id "compound unique (user_challenge_id, order)"
        int order "compound unique, sort order"
        string title "max 200 chars"
        object expression "AST: {kind:type_in|size_in|..., selectors/rules}"
        object constraints "{min_count:int, ...}"
        string status "enum:todo,in_progress,done, index"
        object metrics "DENORM: {current_count:int, ...} computed values"
        object progress "DENORM: {percent:double, tasks_done:int, tasks_total:int, checked_at:ISODate}"
        ISODate start_found_at
        ISODate completed_at
        ISODate last_evaluated_at
        ISODate created_at
        ISODate updated_at
    }
    
    progress {
        ObjectId _id PK
        ObjectId user_challenge_id "compound (user_challenge_id, -checked_at)"
        ISODate checked_at "compound index DESC, time-series key"
        object aggregate "DENORM: {percent, tasks_done, tasks_total} calculated from tasks[]"
        array tasks "[{task_id, status, progress:{percent, tasks_done, tasks_total, checked_at}, metrics:{current_count, min_count}, constraints, aggregate}]"
        string message
        string engine_version
        ISODate created_at "append-only, no updated_at"
    }
    
    targets {
        ObjectId _id PK
        ObjectId user_id "index"
        ObjectId user_challenge_id "compound (user_challenge_id, -score, pinned)"
        ObjectId cache_id "compound unique (user_challenge_id, cache_id)"
        ObjectId primary_task_id "FK→user_challenge_tasks._id"
        ObjectId[] satisfies_task_ids "FK→user_challenge_tasks._id[]"
        double score "compound index DESC"
        string[] reasons "human-readable explanations"
        bool pinned "compound index, user flag"
        Point loc "DENORM from caches.loc, 2dsphere for geoNear"
        object diagnostics "{matched:[], subscores:{tasks, urgency, geo}, evaluated_at}"
        ISODate created_at
        ISODate updated_at
    }
```
<!-- pagebreak -->
## 5.3 Modèle Cache
```python
# backend/app/models/cache.py
# Modèle principal d'une géocache (métadonnées, typage, localisation, attributs, stats).

from __future__ import annotations
import datetime as dt
from typing import Any, Literal
from pydantic import BaseModel, ConfigDict, Field
from app.core.bson_utils import MongoBaseModel, PyObjectId
from app.core.utils import now

class CacheAttributeRef(BaseModel):
    """Référence d'attribut de cache.

    Description:
        Lien vers un document `cache_attributes` avec indication du sens (positif/négatif).

    Attributes:
        attribute_doc_id (PyObjectId): Référence à `cache_attributes._id`.
        is_positive (bool): True si l'attribut est affirmatif, False s'il est négatif.
    """

    attribute_doc_id: PyObjectId  # référence à cache_attributes._id
    is_positive: bool  # attribut positif (True) ou négatif (False)

    # Sous-modèle: ajouter model_config pour gérer PyObjectId partout (nested)
    model_config = ConfigDict(arbitrary_types_allowed=True, json_encoders={PyObjectId: str})

class CacheBase(BaseModel):
    """Champs de base d'une géocache.

    Description:
        Structure commune pour la création/lecture des caches : identifiants GC, typage,
        localisation (lat/lon + GeoJSON), attributs, difficultés/terrain, dates et stats.
    """

    GC: str
    title: str
    description_html: str | None = None
    url: str | None = None
    # Typage / classement
    type_id: PyObjectId | None = None  # ref -> CacheType
    size_id: PyObjectId | None = None  # ref -> CacheSize
    # Localisation
    country_id: PyObjectId | None = None  # ref -> Country
    state_id: PyObjectId | None = None  # ref -> State
    lat: float | None = None
    lon: float | None = None
    # GeoJSON pour index 2dsphere (coordonnées [lon, lat])
    loc: dict[str, Any] | None = None
    elevation: int | None = None  # en mètres (optionnel)
    location_more: dict[str, Any] | None = None  # infos libres (ville, département...)
    # Caractéristiques
    difficulty: float | None = None  # 1.0 .. 5.0
    terrain: float | None = None  # 1.0 .. 5.0
    attributes: list[CacheAttributeRef] = Field(default_factory=list)
    # Dates & stats
    placed_at: dt.datetime | None = None
    owner: str | None = None
    favorites: int | None = None
    status: Literal["active", "disabled", "archived"] | None = None

# class CacheCreate / CacheUpdate

class Cache(MongoBaseModel, CacheBase):
    """Document Mongo d'une géocache (avec horodatage).

    Description:
        Étend `CacheBase` avec les champs de traçabilité (_id, created_at, updated_at).
    """

    created_at: dt.datetime = Field(default_factory=lambda: now())
    updated_at: dt.datetime | None = None
```

## 5.2 Modèle User Challenge
```python
# backend/app/models/user_challenge.py
# État d'un challenge pour un utilisateur (statuts déclarés/calculés, logique UC, notes, progress).

from __future__ import annotations
import datetime as dt
from typing import Literal
from pydantic import Field
from app.core.bson_utils import MongoBaseModel, PyObjectId
from app.core.utils import now
from app.models._shared import ProgressSnapshot
from app.models.challenge_ast import UCLogic

class UserChallenge(MongoBaseModel):
    """Document Mongo « UserChallenge ».

    Description:
        Lie un utilisateur à un challenge, stocke le statut utilisateur (déclaratif) et le
        statut calculé (évaluation UC logic), ainsi que l'override manuel et un snapshot courant.

    Attributes:
        user_id (PyObjectId): Réf. utilisateur.
        challenge_id (PyObjectId): Réf. challenge.
        status (Literal['pending','accepted','dismissed','completed']): Statut déclaré.
        computed_status (Literal[...] | None): Statut calculé.
        manual_override (bool): Override manuel actif.
        override_reason (str | None): Justification d'override.
        overridden_at (datetime | None): Date override.
        logic (UCLogic | None): Logique d'agrégation des tasks.
        progress (ProgressSnapshot | None): Snapshot global courant.
        notes (str | None): Notes libres.
        created_at (datetime): Création (local).
        updated_at (datetime | None): MAJ.
    """

    user_id: PyObjectId
    challenge_id: PyObjectId
    # Déclaration UTILISATEUR (peut être "completed" même si non satisfaisant algorithmiquement)
    status: Literal["pending", "accepted", "dismissed", "completed"] = "pending"
    # Statut CALCULÉ par l'évaluation (UCLogic sur les tasks)
    computed_status: Literal["pending", "accepted", "dismissed", "completed"] | None = None
    # Traçabilité de l'override
    manual_override: bool = False
    override_reason: str | None = None
    overridden_at: dt.datetime | None = None
    logic: UCLogic | None = None
    # Aggregated, current snapshot for the whole challenge (redundant with history in Progress collection)
    progress: ProgressSnapshot | None = None
    notes: str | None = None
    # Projection
    estimated_completion_at: dt.datetime | None = None
    created_at: dt.datetime = Field(default_factory=lambda: now())
    updated_at: dt.datetime | None = None
```

## 5.3 Modèle User Challenge Task
```python
# backend/app/models/user_challenge_task.py
# Tâche déclarée dans un UserChallenge : expression AST, contraintes, statut et métriques.

from __future__ import annotations
import datetime as dt
from pydantic import Field
from app.core.bson_utils import MongoBaseModel, PyObjectId
from app.core.utils import now
from app.models._shared import ProgressSnapshot
from app.models.challenge_ast import TaskExpression

class UserChallengeTask(MongoBaseModel):
    """Document Mongo « UserChallengeTask ».

    Description:
        Contient l'expression AST (sélecteur de caches), les contraintes (ex. min_count),
        le statut manuel, des métriques calculées et un snapshot de progression.

    Attributes:
        user_challenge_id (PyObjectId): Réf. UC parent.
        order (int): Ordre d'affichage.
        title (str): Titre de la tâche.
        expression (TaskExpression): AST de sélection.
        constraints (dict): Contraintes (ex. {'min_count': 4}).
        status (str): 'todo' | 'in_progress' | 'done'.
        metrics (dict): Métriques (ex. {'current_count': 3}).
        progress (ProgressSnapshot | None): Snapshot courant.
        last_evaluated_at (datetime | None): Dernière évaluation.
        created_at (datetime): Création (local).
        updated_at (datetime | None): MAJ.
    """

    user_challenge_id: PyObjectId
    order: int = 0
    title: str
    expression: TaskExpression
    constraints: dict = Field(default_factory=dict)  # ex: {"min_count": 4}
    status: str = Field(default="todo")  # todo | in_progress | done
    metrics: dict = Field(default_factory=dict)  # ex: {"current_count": 3}
    # Current aggregated snapshot for this task (history is in Progress collection)
    progress: ProgressSnapshot | None = None
    start_found_at: dt.datetime | None = None
    completed_at: dt.datetime | None = None

    last_evaluated_at: dt.datetime | None = None
    created_at: dt.datetime = Field(default_factory=lambda: now())
    updated_at: dt.datetime | None = None

UserChallengeTask.model_rebuild()
```

## 5.4 Modèle Task Expression
```python
# backend/app/models/challenge_ast.py
# AST décrivant les sélecteurs/règles de tâches et la logique (and/or/not) côté UserChallenge.

from __future__ import annotations
from datetime import date
from typing import Any, Literal, Union
from pydantic import BaseModel, ConfigDict, Field
from app.core.bson_utils import PyObjectId

class ASTBase(BaseModel):
    """Base Pydantic pour tous les noeuds AST.

    Description:
        Active les encoders `PyObjectId` et `populate_by_name`, tolère les types arbitraires,
        afin d'obtenir un JSON/OpenAPI propre pour Swagger.
    """
    model_config = ConfigDict(
        arbitrary_types_allowed=True,
        json_encoders={PyObjectId: str},
        populate_by_name=True,
    )

# ---- Cache-level leaves ----
## --- Selectors ---
class TypeSelector(ASTBase):
    """Sélecteur par type de cache.

    Attributes:
        cache_type_doc_id (PyObjectId | None): Réf. `cache_types._id`.
        cache_type_id (int | None): Identifiant numérique global.
        cache_type_code (str | None): Code type (ex. "whereigo").
    """
    cache_type_doc_id: PyObjectId | None = None
    cache_type_id: int | None = None
    cache_type_code: str | None = Field(
        default=None, description="Cache type code, e.g. 'whereigo'"
    )

# class SizeSelector / StateSelector / CountrySelector / AttributeSelector

## --- Rules ---
class RuleTypeIn(ASTBase):
    """Règle: type ∈ {…}."""
    kind: Literal["type_in"] = "type_in"
    types: list[TypeSelector]

# class RuleSizeIn / RulePlacedYear / RulePlacedBefore / RulePlacedAfter / RuleStateIn / RuleCountryIs / RuleDifficultyBetween / RuleTerrainBetween / RuleAttributes

# ---- Aggregate leaves (apply to the set of eligible finds) ----
class RuleAggSumDifficultyAtLeast(ASTBase):
    """Règle agrégée: somme(difficulté) ≥ min_total (sur l'ensemble de trouvailles éligibles)."""
    kind: Literal["aggregate_sum_difficulty_at_least"] = "aggregate_sum_difficulty_at_least"
    min_total: int = Field(ge=1)

# class RuleAggSumTerrainAtLeast / RuleAggSumDiffPlusTerrAtLeast / RuleAggSumAltitudeAtLeast

TaskLeaf = Union[RuleTypeIn, RuleSizeIn, ..., RuleAggSumDifficultyAtLeast, ...]

class TaskAnd(ASTBase):
    """noeud logique AND.
    Attributes:
        nodes (list[TaskAnd | TaskOr | TaskNot | TaskLeaf]): Sous-noeuds.
    """
    kind: Literal["and"] = "and"
    nodes: list[TaskAnd | TaskOr | TaskNot | TaskLeaf]

# class TaskOr / TaskNot

TaskExpression = TaskAnd | TaskOr | TaskNot | TaskLeaf
TaskAnd.model_rebuild()
TaskOr.model_rebuild()
TaskNot.model_rebuild()


# ---- UC-level logic (composition by task ids, unchanged) ----
class UCAnd(ASTBase):
    """Logique UC: AND des `task_ids`."""
    kind: Literal["and"] = "and"
    task_ids: list[PyObjectId]

# class UCOr / UCNot

UCLogic = Union[UCAnd, UCOr, UCNot]

# Les kinds logiques et les kinds "feuilles" (règles) connus
_LOGICAL_KINDS = {"and", "or", "not"}
_RULE_KINDS = {"attributes", "type_in", ..., "aggregate_sum_difficulty_at_least",...}

def preprocess_expression_default_and(expr: Any) -> Any:
    """Normalise une expression courte en `AND` explicite.

    Description:
        Transforme les écritures abrégées (sans `kind`, avec règles directes, etc.)
        en une structure canonique où `kind='and'` et les règles sont dans `nodes`.
        Appelée **avant** la validation Pydantic de l'AST.

    Args:
        expr (Any): Expression brute (dict/objets/…).

    Returns:
        Any: Expression normalisée (dict) prête pour la validation.
    """
    # Cas non-dict (list, str, etc.) → inchangé
    if not isinstance(expr, dict):
        return expr

    # Si pas de 'kind' → c'est un AND implicite
    if "kind" not in expr:
        # Si déjà une liste de 'nodes', on force 'and'
        if "nodes" in expr and isinstance(expr["nodes"], list):
            return {"kind": "and", "nodes": expr["nodes"]}

        # Détection d'une "règle courte" (attributs/typage directs)
        looks_like_rule = any(k in expr for k in ("attributes", "type_ids", "codes", "size_ids", "year", "date", "state_ids", "country_id", "min", "max", "min_total"))
        if looks_like_rule:
            return {"kind": "and", "nodes": [expr]}

        # Sinon, on met quand même un AND vide (laisser la validation gérer)
        return {"kind": "and", "nodes": expr.get("nodes", [])}

    # Si 'kind' est une règle au sommet → envelopper dans un AND
    k = expr.get("kind")
    if isinstance(k, str) and k in _RULE_KINDS:
        return {"kind": "and", "nodes": [expr]}

    # Si 'kind' est logique mais sans nodes et qu'on voit des champs de règle,
    # on transforme en nodes=[ ce dict moins 'kind' ] (rare, mais utile)
    if isinstance(k, str) and k in _LOGICAL_KINDS and not expr.get("nodes"):
        looks_like_rule = any(field in expr for field in ("attributes", "type_ids", "codes", "size_ids", "year", "date", "state_ids", "country_id", "min", "max", "min_total"))
        if looks_like_rule:
            rule_like = {kk: vv for kk, vv in expr.items() if kk != "kind"}
            return {"kind": k, "nodes": [rule_like]}

    # Déjà canonique
    return expr
```