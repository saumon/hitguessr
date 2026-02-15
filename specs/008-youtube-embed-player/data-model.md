# Data Model: Lecteur YouTube Embarqué

**Feature**: 008-youtube-embed-player
**Date**: 2026-02-14

## Résumé

Cette feature ne nécessite **aucune modification du modèle de données**.

L'attribut `url` existant sur le modèle `Proposal` contient déjà les liens YouTube. La détection et l'embedding se font côté présentation (helper + vue).

## Entités existantes utilisées

### Proposal

| Attribut | Type | Description |
| -------- | ---- | ----------- |
| `url` | string | URL de la proposition musicale (peut être YouTube ou autre) |
| `player_id` | integer | FK vers User qui a fait la proposition |
| `game_id` | integer | FK vers Game |

**Relations**:

- `belongs_to :game`
- `belongs_to :player` (User)
- `has_many :guesses`

### Guess

| Attribut | Type | Description |
| -------- | ---- | ----------- |
| `proposal_id` | integer | FK vers Proposal |
| `guesser_id` | integer | FK vers User qui devine |
| `guessed_player_id` | integer | FK vers User deviné |

## Pourquoi pas de migration

- Le contenu YouTube est détecté dynamiquement via regex sur `proposal.url`
- Pas de stockage de métadonnées YouTube (video_id, title, etc.)
- Pas de cache des iframes côté serveur
- Le helper analyse l'URL à chaque rendu

## Considérations futures (hors scope)

Si le besoin émerge de :

- Stocker le video_id YouTube pour analytics → ajouter colonne `youtube_video_id`
- Cacher les thumbnails → utiliser Active Storage
- Valider que l'URL YouTube existe → appel API YouTube au submit

Ces évolutions nécessiteraient une migration, mais ne sont pas dans le scope actuel.
