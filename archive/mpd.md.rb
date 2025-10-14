```mermaid
%% caption: Modèle physique de données (MongoDB)
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

  CACHES ||--o{ CACHE_ATTRIBUTES : "has_attributes"
    
    COUNTRIES {
      uuid id
      string name
      created_at datetime
      updated_at datetime
    }
    
    STATES {
      uuid id
      string name
      uuid country_id
      created_at datetime
      updated_at datetime
    }
    
    CACHE_ATTRIBUTES  {
      uuid id
      string code 
      string name
      string name_reverse
      created_at datetime
      updated_at datetime
    }

    USERS {
      uuid id
      string email "UNIQUE"
      string username "UNIQUE"
      enum role
      boolean email_verified
    }
    
    CACHES {
      uuid id
      string gc_code "UNIQUE"
      geoJson loc "2dsphere"
      uuid type_id
      uuid size_id
      uuid state_id
      array[uuid] attribute_ids
      int favorites
      date placed_at
      created_at datetime
      updated_at datetime
    }
    
    CACHE_TYPES {
      uuid id
      string name
      string description
    }
    
    CACHE_SIZES {
      uuid id
      string name
      string description
    }
    
    FOUND_CACHES {
      uuid id
      uuid user_id
      uuid cache_id
      date found_at
    }
    
    CHALLENGES {
      uuid id
      string name
      string description
    }
    
    USER_CHALLENGES {
      uuid id
      uuid user_id
      uuid challenge_id
      string status
      string notes
      date created_at
      date updated_at
    }
    
    USER_CHALLENGE_TASKS {
      uuid id
      uuid user_challenge_id
      int order
      string title
      string ast_expression
      string constraints
      string status
    }
    
    PROGRESS {
      uuid id
      uuid user_challenge_id
      date checked_at
      string aggregate
      string tasks
      date estimated_completion_at
    }
    
    TARGETS {
      uuid id
      uuid user_challenge_id
      uuid cache_id
      float score
      string matched_task_ids
      float distance_km
    }
```
