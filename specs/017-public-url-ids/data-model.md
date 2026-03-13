# Data Model: Public IDs For Public URLs

## Overview

This feature adds public, non-sequential IDs to `Game` and `Team` while keeping internal numeric primary keys unchanged.

## Entity: Game

- Existing fields: `id`, `team_id`, `status`, timestamps.
- New field: `public_id` (string, not null, unique in `games`).
- Public ID format: `gm_<segment>` where `<segment>` matches `[A-Za-z0-9]{8}`.
- Lifecycle:
  - On create: generate `public_id` if absent.
  - On read from public routes: resolve by `public_id`, not numeric `id`.

Validation rules:

- `public_id` presence.
- `public_id` format strict regex.
- segment uniqueness globally across `games` + `teams` (application-level guard).

## Entity: Team

- Existing fields: `id`, `name`, `organizer_id`, timestamps.
- New field: `public_id` (string, not null, unique in `teams`).
- Public ID format: `tm_<segment>` where `<segment>` matches `[A-Za-z0-9]{8}`.
- Lifecycle:
  - On create: generate `public_id` if absent.
  - On read from public routes: resolve by `public_id`, not numeric `id`.

Validation rules:

- `public_id` presence.
- `public_id` format strict regex.
- segment uniqueness globally across `games` + `teams` (application-level guard).

## Value Object: Public Identifier

Structure:

- `prefix`: `gm` or `tm`.
- `separator`: `_`.
- `segment`: exactly 8 base62 chars.

Examples:

- Game: `gm_Az09bY2Q`
- Team: `tm_7xP0LmN2`

Invalid examples (must return 404 on public endpoints):

- `123`
- `gm_abc`
- `tm_abcdefgh!`
- `xx_ABCDEFGH`

## Concern: PublicId

Location: `app/models/concerns/public_id.rb`

Responsibilities:

- Register `before_create` callback.
- Generate candidate IDs with model-specific prefix.
- Enforce retry policy (max 5 attempts).
- Ensure global segment uniqueness across `Game` and `Team`.

Model contract:

- Each model provides `public_id_prefix` (`gm` / `tm`).
- Concern may expose helper methods (`public_id_segment`, `public_id_format`).

## Database Changes

1. Add column `public_id` to `games` and `teams`.
2. Backfill existing rows with valid IDs.
3. Add unique index on each table `public_id`.
4. Set `NOT NULL` on both columns.

Notes:

- Per-table unique indexes are mandatory.
- Global segment uniqueness is enforced in app logic by checking both tables before assignment.

## State Transitions / Failure States

Creation transition:

1. Build model (`public_id` blank).
2. Generate candidate (`<prefix>_<8 base62>`).
3. Check collisions (same table + other table segment).
4. Save success OR retry.
5. After 5 failed retries: raise controlled error, log technical event, return failure.

Public lookup transition:

1. Receive path parameter.
2. Validate format/prefix.
3. Resolve by `public_id`.
4. Not found or invalid => 404 (no redirect, no leak).
