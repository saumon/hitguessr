# Data Model: Team-Scoped Game Numbering

## Overview

This feature introduces a persisted team-local game number on `Game` so each `Team` has its own stable sequence `1, 2, 3, ...`.

## Entity: Team

Existing core fields:

- `id` (PK)
- `public_id` (UK)
- `name`
- `organizer_id`

Relationships:

- `has_many :games`

Role in this feature:

- Defines the numbering scope.
- Provides lock scope for safe number allocation during creation.

## Entity: Game

Existing core fields:

- `id` (PK)
- `public_id` (UK)
- `team_id` (FK -> teams.id)
- `status`
- `created_at`, `updated_at`

New field:

- `team_game_number` (integer, positive, persisted)

Validation rules:

- `team_game_number` presence when `team_id` is present.
- `team_game_number > 0`.
- uniqueness of `team_game_number` scoped to `team_id`.
- `team_id` immutable after create.

Relationships:

- `belongs_to :team` (immutable link)

## Derived Value: Next Team Game Number

Definition:

- `next_number = max(team.games.team_game_number) + 1`, defaulting to 1 when no prior game exists.

Allocation rules:

1. Run inside team-level critical section (`Team#with_lock`).
2. Assign `next_number` before insert.
3. On unique collision, retry up to 3 times by recomputing max.
4. Raise controlled error only when retries are exhausted.

## Database Constraints

Planned schema changes:

1. Add `games.team_game_number`.
2. Backfill all historical rows with `team_id` using deterministic order `created_at ASC, id ASC` per team.
3. Add unique index: `index_games_on_team_id_and_team_game_number`.
4. Add check constraint or equivalent validation path enforcing `team_game_number > 0`.
5. Set `team_game_number` to `NOT NULL` once backfill is complete.

Notes:

- Keep existing `games.id` and `games.public_id` unchanged; they are not renumbered.
- Deleted games do not trigger renumbering of existing rows.

## State Transitions

### Create Game

1. Receive request to create game for a team.
2. Lock team row.
3. Compute and assign next `team_game_number`.
4. Insert game row.
5. Commit transaction.

Failure states:

- Unique collision on `(team_id, team_game_number)` => automatic bounded retry.
- Validation failure unrelated to numbering => return `422` with form errors.

### Update Existing Game

- `team_game_number` remains unchanged.
- `team_id` change attempt is rejected.

### Delete Game

- Row is removed.
- Remaining game numbers are preserved.
- Next creation uses current max + 1 (no gap filling).
