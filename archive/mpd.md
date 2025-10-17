```mermaid
erDiagram
    users ||--o{ user_challenges&nbsp;: "user_id"
    users ||--o{ found_caches&nbsp;: "user_id"
    users ||--o{ targets&nbsp;: "user_id"
    
    caches ||--o{ found_caches&nbsp;: "cache_id"
    caches ||--o{ challenges&nbsp;: "cache_id"
    caches ||--o{ targets&nbsp;: "cache_id"
    caches }o--|| cache_types&nbsp;: "type_id"
    caches }o--|| cache_sizes&nbsp;: "size_id"
    caches }o--|| countries&nbsp;: "country_id"
    caches }o--o| states&nbsp;: "state_id"
    
    challenges ||--o{ user_challenges&nbsp;: "challenge_id"
    
    user_challenges ||--o{ user_challenge_tasks&nbsp;: "user_challenge_id"
    user_challenges ||--o{ progress&nbsp;: "user_challenge_id"
    user_challenges ||--o{ targets&nbsp;: "user_challenge_id"
    
    countries ||--o{ states&nbsp;: "country_id"
    
    user_challenge_tasks ||--o{ targets&nbsp;: "primary_task_id"
    
    users {
        ObjectId _id PK "Index unique"
        string username "Index unique"
        string email "Index unique"
        string role
        boolean is_active
        boolean is_verified
        object location "GeoJSON Point, index 2dsphere"
        object preferences
        array challenges "ObjectId[]"
        string verification_code
        datetime verification_expires_at
        datetime created_at
        datetime updated_at
    }
    
    caches {
        ObjectId _id PK "Index unique"
        string GC "Index unique"
        string title
        string description_html
        string url
        ObjectId type_id "Index, FK cache_types"
        ObjectId size_id "Index, FK cache_sizes"
        ObjectId country_id "Index, FK countries"
        ObjectId state_id "Index, FK states"
        float lat
        float lon
        object loc "GeoJSON Point, index 2dsphere"
        int elevation
        object location_more
        float difficulty "Index"
        float terrain "Index"
        array attributes "CacheAttributeRef[]"
        datetime placed_at "Index"
        string owner
        int favorites
        string status
        datetime created_at
        datetime updated_at
    }
    
    cache_types {
        ObjectId _id PK
        string name "Index"
        string code
        array aliases
        datetime created_at
        datetime updated_at
    }
    
    cache_sizes {
        ObjectId _id PK
        string name "Index"
        string code
        int order
        datetime created_at
        datetime updated_at
    }
    
    cache_attributes {
        ObjectId _id PK
        int cache_attribute_id "Index unique"
        string txt "Index unique"
        string name
        string name_reverse
        array aliases
        datetime created_at
        datetime updated_at
    }
    
    countries {
        ObjectId _id PK
        string name "Index unique"
        string code
        datetime created_at
        datetime updated_at
    }
    
    states {
        ObjectId _id PK
        string name "Index"
        string code
        ObjectId country_id "Index composé (country_id, name)"
        datetime created_at
        datetime updated_at
    }
    
    found_caches {
        ObjectId _id PK
        ObjectId user_id "Index composé (user_id, cache_id)"
        ObjectId cache_id "Index composé (user_id, cache_id)"
        date found_date "Index"
        string notes
        datetime created_at
        datetime updated_at
    }
    
    challenges {
        ObjectId _id PK
        ObjectId cache_id "Index unique"
        string name
        string description
        object meta
        datetime created_at
        datetime updated_at
    }
    
    user_challenges {
        ObjectId _id PK
        ObjectId user_id "Index composé (user_id, challenge_id)"
        ObjectId challenge_id "Index composé (user_id, challenge_id)"
        string status "Index"
        string computed_status
        boolean manual_override
        string override_reason
        datetime overridden_at
        object logic "UCLogic AST"
        object progress "ProgressSnapshot"
        string notes
        datetime estimated_completion_at
        datetime created_at "Index"
        datetime updated_at
    }
    
    user_challenge_tasks {
        ObjectId _id PK
        ObjectId user_challenge_id "Index composé (user_challenge_id, order)"
        int order "Index composé (user_challenge_id, order)"
        string title
        object expression "TaskExpression AST"
        object constraints
        string status "Index"
        object metrics
        object progress "ProgressSnapshot"
        datetime start_found_at
        datetime completed_at
        datetime last_evaluated_at
        datetime created_at
        datetime updated_at
    }
    
    progress {
        ObjectId _id PK
        ObjectId user_challenge_id "Index composé (user_challenge_id, checked_at DESC)"
        datetime checked_at "Index composé (user_challenge_id, checked_at DESC)"
        object aggregate "ProgressSnapshot"
        array tasks "TaskProgressItem[]"
        string message
        string engine_version
        datetime created_at
    }
    
    targets {
        ObjectId _id PK
        ObjectId user_id "Index"
        ObjectId user_challenge_id "Index composé (user_challenge_id, score DESC)"
        ObjectId cache_id "Index composé (user_challenge_id, cache_id unique)"
        ObjectId primary_task_id "Index"
        array satisfies_task_ids "ObjectId[]"
        float score "Index composé (user_challenge_id, score DESC)"
        array reasons
        boolean pinned "Index"
        object loc "GeoJSON Point, index 2dsphere"
        object diagnostics
        datetime created_at
        datetime updated_at
    }
```