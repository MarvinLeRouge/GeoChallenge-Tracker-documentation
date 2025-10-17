# Documentation API - GeoChallenge Tracker

## Health

- \httpget `/ping` - Vérification de santé de l'API

## Auth

- \httppost `/auth/register` - Inscription d'un nouvel utilisateur
- \httppost `/auth/login` - Connexion d'un utilisateur
- \httppost `/auth/refresh` - Renouvellement du token d'accès
- \httpget `/auth/verify-email` - Vérification d'email par code
- \httppost `/auth/verify-email` - Vérification d'email via POST
- \httppost `/auth/resend-verification` - Renvoi du code de vérification

## Caches

- \httppost `/caches/upload-gpx` - Importe des caches depuis un fichier GPX/ZIP
- \httppost `/caches/by-filter` - Recherche de caches par filtres
- \httpget `/caches/within-bbox` - Caches dans une bounding box
- \httpget `/caches/within-radius` - Caches autour d'un point (rayon)
- \httpget `/caches/{gc}` - Récupère une cache par code GC
- \httpget `/caches/by-id/{id}` - Récupère une cache par identifiant MongoDB

## Caches Elevation

- \httppost `/caches_elevation/caches/elevation/backfill` - Backfill de l'altitude manquante (admin)

## Challenges

- \httppost `/challenges/refresh-from-caches` - (Re)crée les challenges depuis les caches 'challenge'

## My Challenges

- \httppost `/my/challenges/sync` - Synchroniser les UserChallenges manquants
- \httpget `/my/challenges` - Lister mes UserChallenges
- \httppatch `/my/challenges` - Patch en lot de plusieurs UserChallenges
- \httpget `/my/challenges/{uc_id}` - Détail d'un UserChallenge
- \httppatch `/my/challenges/{uc_id}` - Modifier statut/notes d'un UserChallenge

## My Challenge Tasks

- \httpget `/my/challenges/{uc_id}/tasks` - Lister les tâches d'un UserChallenge
- \httpput `/my/challenges/{uc_id}/tasks` - Remplacer toutes les tâches d'un UserChallenge
- \httppost `/my/challenges/{uc_id}/tasks/validate` - Valider une liste de tâches (sans persistance)

## My Challenge Progress

- \httpget `/my/challenges/{uc_id}/progress` - Obtenir le dernier snapshot et l'historique court
- \httppost `/my/challenges/{uc_id}/progress/evaluate` - Évaluer et enregistrer un snapshot immédiat
- \httppost `/my/challenges/new/progress` - Évaluer le premier snapshot pour les challenges sans progression

## Targets

- \httppost `/my/challenges/{uc_id}/targets/evaluate` - Évaluer et persister les targets d'un UserChallenge
- \httpget `/my/challenges/{uc_id}/targets` - Lister les targets d'un UserChallenge
- \httpdelete `/my/challenges/{uc_id}/targets` - Supprimer toutes les targets d'un UserChallenge
- \httpget `/my/challenges/{uc_id}/targets/nearby` - Lister les targets proches d'un point (par UC)
- \httpget `/my/targets` - Lister toutes mes targets (tous challenges)
- \httpget `/my/targets/nearby` - Lister les targets proches d'un point (tous challenges)

## My Profile

- \httpget `/my/profile/location` - Obtenir ma dernière localisation
- \httpput `/my/profile/location` - Enregistrer ou mettre à jour ma localisation
- \httpget `/my/profile` - Obtenir mon profil

## Maintenance

- \httpget `/maintenance` - Maintenance Get 1
- \httppost `/maintenance` - Maintenance Post 1