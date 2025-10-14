```mermaid
erDiagram
    USER ||--o{ USER_CHALLENGE&nbsp;: "possède"
    USER ||--o{ FOUND_CACHE&nbsp;: "a trouvé"
    USER ||--o{ TARGET&nbsp;: "cible"
    
    CACHE ||--o{ FOUND_CACHE&nbsp;: "est trouvée par"
    CACHE ||--o{ CHALLENGE&nbsp;: "contient"
    CACHE ||--o{ TARGET&nbsp;: "est ciblée"
    CACHE }o--|| CACHE_TYPE&nbsp;: "a pour type"
    CACHE }o--|| CACHE_SIZE&nbsp;: "a pour taille"
    CACHE }o--|| COUNTRY&nbsp;: "située dans"
    CACHE }o--o| STATE&nbsp;: "située dans"
    CACHE }o--o{ CACHE_ATTRIBUTE&nbsp;: "possède (via ref)"
    
    CHALLENGE ||--o{ USER_CHALLENGE&nbsp;: "assigné à"
    
    USER_CHALLENGE ||--o{ USER_CHALLENGE_TASK&nbsp;: "contient"
    USER_CHALLENGE ||--o{ PROGRESS&nbsp;: "suit"
    USER_CHALLENGE ||--o{ TARGET&nbsp;: "génère"
    
    COUNTRY ||--o{ STATE&nbsp;: "contient"
    
    USER {
        ObjectId _id PK
        string username UK
        string email UK
        string role
        bool is_active
        bool is_verified
        UserLocation location
        Preferences preferences
        datetime created_at
        datetime updated_at
    }
    
    CACHE {
        ObjectId _id PK
        string GC UK
        string title
        string description_html
        string url
        ObjectId type_id FK
        ObjectId size_id FK
        ObjectId country_id FK
        ObjectId state_id FK
        float lat
        float lon
        GeoJSON loc
        int elevation
        float difficulty
        float terrain
        List attributes
        datetime placed_at
        string owner
        int favorites
        string status
        datetime created_at
        datetime updated_at
    }
    
    CACHE_TYPE {
        ObjectId _id PK
        string name
        string code
        List aliases
        datetime created_at
        datetime updated_at
    }
    
    CACHE_SIZE {
        ObjectId _id PK
        string name
        string code
        int order
        datetime created_at
        datetime updated_at
    }
    
    CACHE_ATTRIBUTE {
        ObjectId _id PK
        int cache_attribute_id UK
        string txt
        string name
        string name_reverse
        List aliases
        datetime created_at
        datetime updated_at
    }
    
    COUNTRY {
        ObjectId _id PK
        string name
        string code
        datetime created_at
        datetime updated_at
    }
    
    STATE {
        ObjectId _id PK
        string name
        string code
        ObjectId country_id FK
        datetime created_at
        datetime updated_at
    }
    
    FOUND_CACHE {
        ObjectId _id PK
        ObjectId user_id FK
        ObjectId cache_id FK
        date found_date
        string notes
        datetime created_at
        datetime updated_at
    }
    
    CHALLENGE {
        ObjectId _id PK
        ObjectId cache_id FK
        string name
        string description
        ChallengeMeta meta
        datetime created_at
        datetime updated_at
    }
    
    USER_CHALLENGE {
        ObjectId _id PK
        ObjectId user_id FK
        ObjectId challenge_id FK
        string status
        string computed_status
        bool manual_override
        string override_reason
        datetime overridden_at
        UCLogic logic
        ProgressSnapshot progress
        string notes
        datetime estimated_completion_at
        datetime created_at
        datetime updated_at
    }
    
    USER_CHALLENGE_TASK {
        ObjectId _id PK
        ObjectId user_challenge_id FK
        int order
        string title
        TaskExpression expression
        dict constraints
        string status
        dict metrics
        ProgressSnapshot progress
        datetime start_found_at
        datetime completed_at
        datetime last_evaluated_at
        datetime created_at
        datetime updated_at
    }
    
    PROGRESS {
        ObjectId _id PK
        ObjectId user_challenge_id FK
        datetime checked_at
        ProgressSnapshot aggregate
        List tasks
        string message
        string engine_version
        datetime created_at
    }
    
    TARGET {
        ObjectId _id PK
        ObjectId user_id FK
        ObjectId user_challenge_id FK
        ObjectId cache_id FK
        ObjectId primary_task_id FK
        List satisfies_task_ids
        float score
        List reasons
        bool pinned
        GeoJSON loc
        TargetDiagnostics diagnostics
        datetime created_at
        datetime updated_at
    }
```