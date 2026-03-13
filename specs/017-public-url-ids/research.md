# Research: Public IDs For Public URLs

## Decision 1: Shared concern `PublicId` for ID generation

- Decision: Implement a shared ActiveRecord concern in `app/models/concerns/public_id.rb` and include it in `Game` and `Team`.
- Rationale: Keeps generation logic centralized, testable, and reusable while preserving model-specific prefix rules.
- Alternatives considered:
  - Duplicate callback logic in `Game` and `Team`: rejected due to duplication and drift risk.
  - Service object only: rejected because generation is lifecycle-bound (`before_create`) and concern is idiomatic Rails.

## Decision 2: Prefix mapping must be explicit, not inferred from class name

- Decision: Use explicit prefixes by model (`gm` for Game, `tm` for Team) via class method override or config in concern.
- Rationale: `self.class.name.first(2).downcase` would generate `ga` for Game, which conflicts with the spec requirement `gm_`.
- Alternatives considered:
  - Prefix inferred from class name initials: rejected because it does not satisfy product requirement.
  - Hardcode in concern without override: rejected because not extensible for future public resources.

## Decision 3: Segment format and uniqueness

- Decision: Segment is exactly 8 chars base62 (`[A-Za-z0-9]{8}`), and segment uniqueness is global across Game and Team.
- Rationale: Matches clarified requirements and provides a single collision domain.
- Alternatives considered:
  - Per-type uniqueness only: rejected by clarification.
  - Variable-length segment: rejected by clarification.

## Decision 4: Collision policy on generation

- Decision: Retry generation up to 5 times, then fail with controlled internal error and structured logging.
- Rationale: Prevents infinite retry loops and makes failures observable.
- Alternatives considered:
  - Infinite retry: rejected due to non-terminating risk.
  - One retry then fallback length: rejected because would violate fixed-length rule.

## Decision 5: Migration/deployment strategy

- Decision: Two-phase rollout:
  1. Schema + model support + backfill all historical `games` and `teams`.
  2. Activate public lookup/routing by `public_id` and stop accepting numeric IDs on public endpoints.
- Rationale: Avoids transient unresolved records and aligns with clarified FR-012.
- Alternatives considered:
  - Lazy migration on first access: rejected by clarification.
  - Dual-format permanent support: rejected by clarification (numeric must be 404).

## Decision 6: Persistence constraints

- Decision: Add `public_id` columns on `games` and `teams` with `NOT NULL` and unique indexes per table, plus application-level global collision checks in concern.
- Rationale: DB uniqueness enforces safety per table; concern enforces global segment uniqueness across both tables.
- Alternatives considered:
  - Single shared public_identifiers table: postponed; stronger global DB guarantee but larger refactor than required.

## Decision 7: Test strategy

- Decision: Add model tests for generation/format/retry, integration tests for route resolution via `public_id`, and 404 tests for numeric/invalid IDs.
- Rationale: Covers behavior and regression risk where URLs and finders change.
- Alternatives considered:
  - Controller-only tests: rejected due to insufficient coverage of callback and collision behavior.
