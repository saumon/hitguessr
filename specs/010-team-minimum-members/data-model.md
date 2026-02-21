# Data Model: Seuil minimum de membres

**Feature**: 010-team-minimum-members  
**Date**: 2026-02-21

## Summary

La fonctionnalité réutilise le schéma existant sans migration. Le comportement est porté par des invariants de création de `Game` basés sur le nombre de `Membership` existants pour l'équipe ciblée.

## Entities Involved

### Team

| Attribute | Type | Notes |
| - | - | - |
| id | integer | PK |
| organizer_id | integer | FK vers users |
| name | string | Nom de l'équipe |

**Associations**:

- `has_many :memberships`
- `has_many :members, through: :memberships`
- `has_many :games`

**Rules for this feature**:

- L'équipe doit avoir au moins 3 membres (via memberships) pour autoriser la création d'une partie.

### Membership

| Attribute | Type | Notes |
| - | - | - |
| id | integer | PK |
| team_id | integer | FK vers teams |
| user_id | integer | FK vers users |

**Validation existante**:

- Unicité `(user_id, team_id)`.

**Interpretation in this feature**:

- "Membre actif/confirmé" = membership existant.

### Game

| Attribute | Type | Notes |
| - | - | - |
| id | integer | PK |
| team_id | integer | FK vers teams |
| status | enum integer | `collecting`, `guessing`, `finished` |
| started_at | datetime | Début phase guessing |
| finished_at | datetime | Fin de partie |

**Creation Invariants**:

1. Aucune partie active existante pour l'équipe (règle existante).
2. Au moins 3 memberships pour l'équipe au moment transactionnel de la création (nouvelle règle).

### User

| Attribute | Type | Notes |
| - | - | - |
| id | integer | PK |
| name | string | Affichage |
| email | string | Authentification |

## State Transitions (relevant)

```text
eligible_team (>=3 members, no active game)
  └── create game -> game.status = collecting

ineligible_team (<3 members)
  └── create game attempt -> refused, no game created
```

## Validation Rules Mapping

- FR-001/FR-002/FR-003/FR-009/FR-010/FR-011 impactent l'invariant de création de `Game`.
- FR-004 impose l'absence de création persistée en cas de refus.
- FR-005/FR-006 imposent un feedback explicite côté UX.

## No Schema Changes Required

- Aucune table/colonne/index supplémentaire.
- Changement purement applicatif (contrôleur/modèle/vue/tests/docs).
