# Research: Team-Scoped Game Numbering

## Decision 1: Persisted field name and semantics

- Decision: Add `team_game_number` (integer) on `games`, nullable during migration, then `NOT NULL` for all rows where `team_id` is present.
- Rationale: Requirement explicitly asks for a persisted field; integer keeps sorting/filtering simple and index-friendly.
- Alternatives considered:
  - Compute on read with `ROW_NUMBER()`: rejected because unstable under deletes and expensive for frequent reads.
  - Reuse `games.id`: rejected because global sequence creates holes per team.

## Decision 2: Historical backfill ordering

- Decision: Backfill per team ordered by `created_at ASC, id ASC` and assign numbers starting at 1.
- Rationale: Matches clarified rule (oldest game = 1) and adds deterministic tie-breaker when timestamps are equal.
- Alternatives considered:
  - Order by `id` only: rejected because business clarification is based on creation chronology.
  - Order by status or finished date: rejected because not aligned with user expectation.

## Decision 3: Uniqueness enforcement

- Decision: Add unique composite index on `(team_id, team_game_number)` plus model-level validation.
- Rationale: DB-level guarantee is mandatory for race safety; model validation improves error messaging in normal flow.
- Alternatives considered:
  - Validation only: rejected because unsafe under concurrent inserts.
  - Separate sequence table per team: rejected as unnecessary complexity for current scope.

## Decision 4: Concurrent creation strategy

- Decision: Keep team-scoped lock (`@team.with_lock`) during game creation, compute next number from current max, and add short bounded retry on unique-constraint collision (up to 3 retries with small jitter).
- Rationale: Existing code already serializes create flow; retry hardens behavior for unexpected lock contention/multi-process edge cases and fulfills FR-009.
- Alternatives considered:
  - No retry, fail immediately: rejected because clarified requirement demands recoverable automatic retry.
  - Global app mutex: rejected due to unnecessary throughput impact.

## Decision 5: Team immutability after creation

- Decision: Prevent `team_id` changes on persisted `Game` records (validation `team_id_immutable`).
- Rationale: Required by FR-005a and keeps assigned number stable forever.
- Alternatives considered:
  - Allow reassignment and renumber on move: rejected due to high complexity and instability risk.
  - Allow reassignment while keeping old number: rejected because breaks uniqueness in destination team.

## Decision 6: Display migration path

- Decision: Replace all user-facing game-number displays from global ID/public ID fallback to `team_game_number` with defensive fallback only for transient migration windows.
- Rationale: Ensures UX consistency across list/detail and avoids mixed numbering references.
- Alternatives considered:
  - Partial rollout on one page only: rejected because spec requires coherent display across views.
  - Immediate hard switch without fallback: rejected due to possible deploy-order mismatch.

## Decision 7: Test strategy and performance budget

- Decision: Add model tests (assignment, immutability, uniqueness), controller/integration tests (display and create behavior), and migration test/backfill verification; enforce p95 create latency budget under team lock in local benchmark script.
- Rationale: Covers constitution testing gate and concurrency edge cases with measurable performance target.
- Alternatives considered:
  - Controller tests only: rejected because misses model and migration guarantees.
  - Performance by intuition only: rejected by constitution performance principle.
