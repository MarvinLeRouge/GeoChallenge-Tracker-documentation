```mermaid
%% MLD (NoSQL, agnostique)
erDiagram
  USERS ||--o{ USER_CHALLENGES : "follows"
  USERS ||--o{ FOUND_CACHES    : "records"
  CHALLENGES ||--o{ USER_CHALLENGES : "is_followed_by"
  USER_CHALLENGES ||--o{ USER_CHALLENGE_TASKS : "made_of"

  USER_CHALLENGES ||--o{ PROGRESS : "has_progress_points"
  USER_CHALLENGES ||--o{ TARGETS  : "has_candidates"

  CACHES ||--o{ FOUND_CACHES : "is_found"
  CACHES }o--|| CACHE_TYPES  : "has_type"
  CACHES }o--|| CACHE_SIZES  : "has_size"
  CACHES }o--|| STATES       : "located_in"
  STATES }o--|| COUNTRIES    : "is_in"

  %% N..N conceptuel : Cache a 0..N attributs, un attribut peut concerner 0..N caches
  CACHES }o--o{ CACHE_ATTRIBUTES : "associated_with"

  USERS {
    id id
    email string  "UNIQUE"
    username string "UNIQUE"
    role enum
    email_verified boolean
  }

  CHALLENGES {
    id id
    name string
    description string
  }

  USER_CHALLENGES {
    id id
    status enum
    %% ex: accepté, en_cours, terminé, abandonné
    notes string
  }

  USER_CHALLENGE_TASKS {
    id id
    order int
    title string
    ast_expression string
    constraints string
    status enum
  }

  PROGRESS {
    id id
    checked_at datetime
    aggregate string
    tasks string
    estimated_completion_at date
    %% extrapolation (métier)
  }

  TARGETS {
    id id
    score float
    matched_task_ids string
    distance_km float
  }

  CACHES {
    id id
    gc_code string "UNIQUE"
    loc geo position
    favorites int
    placed_at date
  }

  CACHE_TYPES {
    id id
    name string
    description string
  }

  CACHE_SIZES {
    id id
    name string
    description string
  }

  CACHE_ATTRIBUTES {
    id id
    code string
    name string
    name_reverse string
  }

  STATES {
    id id
    name string
  }

  COUNTRIES {
    id id
    name string
  }

  FOUND_CACHES {
    id id
    found_at date
    %% contrainte métier: (user, cache) UNIQUE
  }
```
