# Phase 1 — Data Model: Gestion des invitations d’équipe

## Entity: TeamInvitation

### Purpose

Représente une demande d’ajout d’un utilisateur à une équipe, envoyée par un organisateur, en attente de réponse du membre invité.

### Fields

- `id` (PK)
- `team_id` (FK -> teams, required)
- `invited_user_id` (FK -> users, required)
- `invited_by_id` (FK -> users, required, organisateur émetteur)
- `status` (enum: `pending`, `accepted`, `refused`, required, default `pending`)
- `responded_at` (datetime, nullable)
- `created_at`, `updated_at`

### Validation Rules

- Unicité d’une invitation en attente par couple (`team_id`, `invited_user_id`) — empêche les doublons (`FR-009`).
- `status` doit appartenir à `{pending, accepted, refused}`.
- `responded_at` requis si `status` est `accepted` ou `refused`.
- `invited_user_id` ne peut pas déjà être membre actif de l’équipe au moment de création (`FR-002`, edge case doublon actif).

### State Transitions

- `pending -> accepted`
- `pending -> refused`
- Tout autre changement est interdit (`FR-010`).
- Transition atomique: une seule première réponse valide est persistée (`FR-013`).

## Entity: Membership (existing)

### Purpose of the Membership entity

Représente l’appartenance active d’un utilisateur à une équipe.

### Fields (existing)

- `id` (PK)
- `team_id` (FK -> teams)
- `user_id` (FK -> users)
- `created_at`, `updated_at`

### Validation Rules (existing + usage)

- Unicité (`user_id`, `team_id`).
- Création depuis invitation acceptée uniquement pour ce flux.

### State Interaction with TeamInvitation

- À l’acceptation d’une invitation `pending`, créer `Membership(team_id, user_id)` si absent, puis marquer invitation `accepted` + `responded_at`.
- En cas de refus, ne pas créer de membership.

## Entity: Team (existing)

### Purpose of the Team entity

Agrège membres actifs et invitations en attente pour affichage dans `/teams`.

### Derived Views/Collections of the Team entity

- `active_members`: via `memberships`
- `pending_invitations`: via `team_invitations.pending`
- Visibilité `pending_invitations`: membres actifs de l’équipe + organisateur (`FR-016`)

## Entity: User (existing)

### Derived Views/Collections of the User entity

- `received_pending_invitations`: invitations `pending` où `invited_user_id = current_user.id` (`FR-015`)

## Referential & Index Strategy

- Index unique partiel recommandé: `team_invitations(team_id, invited_user_id) WHERE status = pending`.
- Index sur `team_id`, `invited_user_id`, `status` pour les listings (`/teams`, bloc membres).

## Domain Invariants

- Un utilisateur peut avoir des invitations de plusieurs équipes en parallèle.
- Un utilisateur peut être membre actif de plusieurs équipes.
- Les invitations en attente n’expirent pas automatiquement (`FR-014`).
- Seul le membre invité peut répondre (`FR-012`).
