# Quickstart: Team-Scoped Game Numbering

## Goal

Implement and validate team-scoped sequential game numbers persisted on `games.team_game_number`.

## Prerequisites

- Ruby 3.4.6 and Bundler installed.
- Dependencies installed: `bundle install`.
- Local DB ready.

## Implementation Steps

1. Add migration for `games.team_game_number`:
   - add nullable integer column,
   - backfill existing games by team using `created_at ASC, id ASC`,
   - add unique index on `(team_id, team_game_number)`,
   - enforce non-null and positive constraint once backfill completes.

2. Update `Game` model:
   - assign next team-local number on create,
   - enforce `team_id` immutability,
   - add validation for scoped uniqueness and positive integer.

3. Harden create flow:
   - keep/create team lock in controller/service path,
   - implement short bounded retry (max 3) on unique collisions.

4. Update UI rendering:
   - list and detail views must display `team_game_number` consistently,
   - avoid user-facing fallback to global identifiers once migration is complete.

5. Add/adjust tests:
   - model tests for numbering and immutability,
   - controller/integration tests for creation and display consistency,
   - migration/backfill verification tests.

## Validation Checklist

- First game of a team gets number `1`.
- New game increments to `max + 1` within same team.
- Different teams keep independent sequences.
- Existing games keep stable number over time.
- Deletion does not renumber remaining games.
- Concurrent creations in same team do not produce duplicates.
- Team reassignment after creation is blocked.

## Test Commands

```bash
# Focused tests
bin/rails test test/models/game_test.rb
bin/rails test test/controllers/games_controller_test.rb
bin/rails test test/integration

# Full suite
bin/rails test
```

## Operational Verification

```bash
# Ensure no missing team-local numbers on team-linked games
bin/rails runner 'puts Game.where.not(team_id: nil).where(team_game_number: nil).count'

# Validate scoped uniqueness quickly
bin/rails runner 'dups = Game.group(:team_id, :team_game_number).having("COUNT(*) > 1").count; puts dups.empty? ? "OK" : dups.inspect'
```

Expected:

- Missing count is `0`.
- Duplicate report is `OK`.
