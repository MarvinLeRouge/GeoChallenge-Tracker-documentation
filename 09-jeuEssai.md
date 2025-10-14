# 9. Jeu d'essai

Afin de valider le système d'import, j'ai préparé 5 fichiers GPX de test&nbsp;:

- fichier 1&nbsp;: 188 caches pour un volume total de 15,6 Mo, contenant uniquement des caches d'un pays pour lequel je n'avais aucune cache enregistrée dans la base, toutes les caches étant situées dans la même région
- fichier 2&nbsp;: 2 576 caches, toutes pré-existantes en base de données
- fichier 3&nbsp;: 1 010 caches, toutes inconnues, situées dans une région inexistante en base de données, mais dans un pays connu
- fichier 4&nbsp;: 200 caches, toutes inconnues, situées dans un même pays, dans une même région, et contenant 21&nbsp;challenges
- fichier 5&nbsp;: volume total de 21Mo


Les résultats attendus étaient donc&nbsp;:

- fichier 1&nbsp;: 188 caches ajoutées, 1 pays créé, 1 région créée
- fichier 2&nbsp;: 2 576 caches existantes, 0 pays créés, 0 région créée
- fichier 3&nbsp;: 1 010 caches ajoutées, 0 pays créés, 1 région créée
- fichier 4&nbsp;: 200 caches ajoutées, 1 pays créé, 1 régions créée, 21 challenges ajoutés
- fichier 5&nbsp;: erreur 413, fichier trop volumineux


Le résultat attendu était l'insertion complète de ces 188 caches ainsi que la création d'une nouvelle entrée pays et région dans la base de données.
L'import s'est déroulé conformément aux attentes&nbsp;: les 188 caches ont été correctement insérées sans duplication (0 cache existant), et le système a bien détecté et créé 1 nouveau pays et 1 nouvelle région. Aucun conflit n'a été rencontré, confirmant ainsi le bon fonctionnement de la logique de déduplication et d'indexation géographique.

Résultats obtenus&nbsp;:
**fichier 1**
```json
{
  "summary": {
    "nb_gpx_files": 1,
    "nb_inserted_caches": 188,
    "nb_existing_caches": 0,
    "nb_inserted_found_caches": 0,
    "nb_updated_found_caches": 0,
    "nb_new_countries": 1,
    "nb_new_states": 1
  },
  "challenges_stats": {
    "matched": 0,
    "created": 0,
    "skipped_existing": 0
  }
}
```

**fichier 2**
```json
{
  "summary": {
    "nb_gpx_files": 1,
    "nb_inserted_caches": 0,
    "nb_existing_caches": 2 576,
    "nb_inserted_found_caches": 0,
    "nb_updated_found_caches": 0,
    "nb_new_countries": 0,
    "nb_new_states": 0
  },
  "challenges_stats": {
    "matched": 0,
    "created": 0,
    "skipped_existing": 0
  }
}
```

<!-- pagebreak -->
**fichier 3**
```json
{
  "summary": {
    "nb_gpx_files": 1,
    "nb_inserted_caches": 1 010,
    "nb_existing_caches": 0,
    "nb_inserted_found_caches": 0,
    "nb_updated_found_caches": 0,
    "nb_new_countries": 0,
    "nb_new_states": 1
  },
  "challenges_stats": {
    "matched": 0,
    "created": 0,
    "skipped_existing": 0
  }
}
```

**fichier 4**
```json
{
  "summary": {
    "nb_gpx_files": 1,
    "nb_inserted_caches": 200,
    "nb_existing_caches": 0,
    "nb_inserted_found_caches": 0,
    "nb_updated_found_caches": 0,
    "nb_new_countries": 1,
    "nb_new_states": 1
  },
  "challenges_stats": {
    "matched": 21,
    "created": 21,
    "skipped_existing": 0
  }
}
```

**fichier 5**
Code&nbsp;: 413
Details&nbsp;: Error: Request Entity Too Large
Response body&nbsp;:
```json
{
  "detail": "Fichier trop volumineux (>20 Mo)."
}
```

On constate que tous les imports du jeu de test se déroulent exactement comme prévu.