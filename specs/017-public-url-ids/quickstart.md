# Quickstart: Public IDs For Public URLs

## Goal

Implement and verify public IDs for `Game` and `Team` with strict 404 behavior for numeric/invalid public endpoint IDs.

## Prerequisites

- Ruby/Bundler installed.
- Project dependencies installed (`bundle install`).
- Test database available.

## Implementation Steps

- Add concern:
  - Create `app/models/concerns/public_id.rb`.
  - Implement callback-based generation (`before_create`) with:
    - explicit per-model prefix (`gm`, `tm`),
    - base62 fixed 8-char segment,
    - max 5 retries,
    - controlled error + logging on exhaustion.

- Update models:
  - Include concern in `Game` and `Team`.
  - Define model-specific prefix contract.
  - Add validations for `public_id` format and presence.

- Database migrations:
  - Add `public_id` columns to `games` and `teams`.
  - Backfill all existing records with valid IDs.
  - Add unique indexes on both tables.
  - Enforce `NOT NULL`.

- Update routing and resource lookup:
  - Ensure all public-facing route generation uses `public_id`.
  - Resolve `Game`/`Team` by `public_id` in controllers (or `to_param` + custom finder strategy).
  - Reject numeric IDs and malformed IDs as 404 with no redirection.

- Verify nested flows:
  - Team-scoped game routes continue to work with team public IDs.
  - Existing authz constraints remain unchanged.

## Validation Checklist

- New `Game` gets `gm_<8 base62>`.
- New `Team` gets `tm_<8 base62>`.
- Historical rows all backfilled before public resolver activation.
- Numeric IDs on public endpoints return 404.
- Invalid prefix/length/chars return 404.
- Collision retry stops at 5 and logs controlled error.

## Test Commands

Run targeted tests first, then full suite:

```bash
# Model tests (public_id generation, format, collision, retry)
bin/rails test test/models/game_test.rb test/models/team_test.rb

# Controller tests (public_id resolution, 404 for numeric/malformed, no-leak)
bin/rails test test/controllers/games_controller_test.rb test/controllers/teams_controller_test.rb

# Integration tests (backfill, end-to-end routing, N+1, no-numeric regression)
bin/rails test test/integration

# Full suite (all 226 tests)
bin/rails test
```

## Validation Results

**Run date**: March 13, 2026

| Suite | Runs | Assertions | Failures | Errors | Status |
| ----- | ---- | --------- | -------- | ------ | ------ |
| Models (game + team) | 85 | 282 | 0 | 0 | PASS |
| Controllers (game + team) | 47 | 147 | 0 | 0 | PASS |
| Integration (routing + backfill) | 12 | 62 | 0 | 0 | PASS |
| **Full suite** | **226** | **716** | **0** | **0** | **PASS** |

All validation checklist items confirmed:

- [x] New `Game` gets `gm_<8 base62>`
- [x] New `Team` gets `tm_<8 base62>`
- [x] Historical rows all backfilled (0 NULL public_id rows)
- [x] Numeric IDs on public endpoints return 404
- [x] Invalid prefix/length/chars return 404
- [x] Collision retry stops at 5 and logs controlled error
- [x] No generated link contains a numeric ID

## Rollout Plan (Two Deployments)

Deployment 1:

- Ship schema changes + concern + model support.
- Run backfill and verify 100% completion.
- Keep public resolution unchanged until completion validated.

Deployment 2:

- Switch public resolution/routing to `public_id`.
- Enforce strict 404 for numeric IDs on public endpoints.
- Monitor logs/metrics for lookup failures.

## Rollback Notes

- If deployment 2 causes routing regressions, revert resolver/routing changes while retaining populated `public_id` columns.
- Do not remove backfilled data.

## Operational Monitoring

### Collision-Exhaustion Alerts

The `PublicId` concern retries ID generation up to 5 times on collision. If retries are exhausted, it logs at `error` level:

```text
[PublicId] EXHAUSTED retries for <ModelName> after 5 attempts
```

**Action**: Search application logs for `[PublicId] EXHAUSTED`. With base62×8 (~218 trillion combinations), this should never trigger at normal scale. If it does, investigate whether the unique index has been corrupted or the random source is degraded.

### Backfill Verification

After running migrations, verify zero NULL public_ids:

```ruby
Game.where(public_id: nil).count  # must be 0
Team.where(public_id: nil).count  # must be 0
```
