# Data Model: Autonomie des membres d'équipe

**Feature**: 012-team-member-autonomy  
**Date**: 2026-03-01

## Summary

La feature ne crée pas de nouvelle entité métier; elle redéfinit la matrice d’autorisations entre `Membership`, `Team` et les transitions de `Game`, avec exigences de cohérence UI et de refus explicite en cas de transition concurrente invalide.

## Entities Involved

### Team

| Attribute | Type | Notes |
| - | - | - |
| id | integer | PK |
| organizer_id | integer | FK `users.id` (rôle organisateur) |
| name | string | Nom d’équipe |

**Rules for this feature**:

- L’organisateur conserve l’exclusivité sur:
  - annulation de partie,
  - ajout/retrait de membres.
- L’organisateur reste éligible aux actions de progression de partie.

### Membership

| Attribute | Type | Notes |
| - | - | - |
| id | integer | PK |
| team_id | integer | FK vers team |
| user_id | integer | FK vers user |

**Rules for this feature**:

- Toute action de partie requiert une appartenance active (`membership`) au moment de l’exécution.
- Si l’utilisateur est retiré de l’équipe, toute action ultérieure est refusée.

### Game

| Attribute | Type | Notes |
| - | - | - |
| id | integer | PK |
| team_id | integer | FK vers team |
| status | enum integer | `collecting`, `guessing`, `finished` |
| started_at | datetime | Début devinettes |
| finished_at | datetime | Fin partie |

**Rules for this feature**:

- Actions de progression autorisées à tout membre d’équipe (organisateur inclus):
  - lancer une partie (`create`),
  - passer aux devinettes (`start_guessing`),
  - terminer (`finish`).
- Action réservée organisateur:
  - annuler (`destroy`) si état annulable.
- Transition concurrente invalide: seconde requête refusée avec conflit explicite “état déjà changé”.

## Permission Matrix

| Action | Organisateur | Membre | Non-membre |
| - | - | - | - |
| Lancer une partie | Oui | Oui | Non |
| Passer aux devinettes | Oui | Oui | Non |
| Terminer la partie | Oui | Oui | Non |
| Annuler la partie | Oui | Non | Non |
| Ajouter un membre | Oui | Non | Non |
| Retirer un membre | Oui | Non | Non |

## State Transitions (relevant)

```text
create game -> collecting

collecting --start_guessing--> guessing
guessing  --finish---------> finished

collecting|guessing --destroy/cancel--> deleted (action organisée)

Concurrency rule:
- If transition T already applied by request A,
  request B attempting same transition is refused with explicit conflict message.
```

## Validation Rules Mapping

- FR-001/FR-002/FR-003/FR-001a: progression autorisée à tout membre de l’équipe (organisateur compris).
- FR-004/FR-005: annulation + gestion membres restent organisateur-only.
- FR-006: contrôle côté serveur à chaque action, y compris URL directe.
- FR-007: transitions invalides refusées, état préservé.
- FR-008/FR-011/FR-012: retour explicite en cas de refus (permission, état incompatible, conflit concurrent).
- FR-009/FR-010: UI cohérente avec droits réels et masquage des actions non autorisées.

## Schema Changes Planned

- Aucun changement de schéma requis.
- Aucun nouveau modèle requis.
