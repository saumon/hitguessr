# Data Model: Randomisation de l’ordre des propositions

**Feature**: 011-randomize-guess-order  
**Date**: 2026-03-01

## Summary

La feature introduit une persistance explicite de l’ordre de devinette par manche via un rang stocké sur chaque `Proposal`, calculé une seule fois lors de la transition vers la phase `guessing`.

## Entities Involved

### Game

| Attribute | Type | Notes |
| - | - | - |
| id | integer | PK |
| status | enum integer | `collecting`, `guessing`, `finished` |
| started_at | datetime | Début de la phase de devinette |
| finished_at | datetime | Fin de partie |
| team_id | integer | FK vers team |

**Rules for this feature**:

- En entrée de `guessing`, le système fige l’ordre des propositions de la manche.
- L’ordre est recalculé indépendamment pour chaque nouvelle manche (nouvelle game).

### Proposal

| Attribute | Type | Notes |
| - | - | - |
| id | integer | PK |
| game_id | integer | FK vers game |
| player_id | integer | FK vers user (auteur) |
| url | string | Lien musique |
| created_at | datetime | Horodatage de soumission |
| guess_order_position | integer | **Nouveau**: position affichée en phase de devinette (1..N) |

**Validation / Invariants**:

- `guess_order_position` est `NULL` tant que la partie est en `collecting`.
- En phase `guessing`/`finished`, toutes les propositions de la manche ont une `guess_order_position` non nulle.
- Dans une même partie, les positions sont uniques et continues (1..N).
- L’ordre affiché est `ORDER BY guess_order_position ASC, id ASC`.

### Guess

| Attribute | Type | Notes |
| - | - | - |
| id | integer | PK |
| proposal_id | integer | FK vers proposal |
| player_id | integer | Joueur qui devine |
| guessed_author_id | integer | Auteur supposé |

**Impact for this feature**:

- Aucun changement de schéma.
- Le flux de création des devinettes consomme les propositions dans l’ordre figé.

## Relationships

- `Game has_many Proposals`
- `Proposal belongs_to Game`
- `Proposal has_many Guesses`

## State Transitions (relevant)

```text
collecting
  ├─ proposals submitted (guess_order_position = NULL)
  └─ start_guessing! -> assign random unique positions 1..N, set status=guessing

guessing
  ├─ guesses/new reads proposals ordered by guess_order_position
  └─ proposals create refused (collecting-only rule)

finished
  └─ historical order remains readable and stable
```

## Validation Rules Mapping

- FR-001: ordre non corrélé au `created_at` grâce au rang randomisé.
- FR-002: même ordre partagé car persistance unique par game.
- FR-003: stabilité garantie par lecture du rang persisté.
- FR-004: nouvelle game => nouveau jeu de rangs.
- FR-005: 0/1 proposition géré sans erreur (pas d’assignation complexe).
- FR-006: position ne révèle pas le moment de soumission.
- FR-007: fermeture des soumissions à l’entrée en devinette.
- FR-008: persistance + réutilisation systématique de l’ordre.

## Schema Changes Planned

- Migration: ajout de `proposals.guess_order_position` (integer, nullable).
- Index recommandé: `(game_id, guess_order_position)` pour lecture ordonnée efficace en devinette.
- Option de robustesse: index unique partiel par game sur `guess_order_position IS NOT NULL`.
