# Tasks: Public IDs For Public URLs

**Input**: Design documents from `/specs/017-public-url-ids/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/, quickstart.md

**Tests**: Tests are REQUIRED for all changed behavior in this feature.

**Organization**: Tasks are grouped by user story so each story can be implemented and tested independently.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare scaffolding for public-id rollout and validation.

- [X] T001 Create shared concern scaffold in app/models/concerns/public_id.rb
- [X] T002 Create feature integration test scaffold in test/integration/public_ids_routing_test.rb
- [X] T003 Create migration test helper for backfill assertions in test/test_helper.rb

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core data/model capabilities that block all user stories.

**⚠️ CRITICAL**: No user story implementation starts before this phase is complete.

- [X] T004 Create migration to add nullable public_id columns in db/migrate/*_add_public_id_to_games_and_teams.rb
- [X] T005 Create migration to backfill existing rows in db/migrate/*_backfill_public_ids_for_games_and_teams.rb
- [X] T006 Create migration to enforce NOT NULL + unique indexes in db/migrate/*_enforce_public_id_constraints.rb
- [X] T007 Implement generation, retry(5), and collision checks in app/models/concerns/public_id.rb
- [X] T008 [P] Include PublicId, prefix contract, and format validation in app/models/game.rb
- [X] T009 [P] Include PublicId, prefix contract, and format validation in app/models/team.rb
- [X] T010 Add controlled internal error logging for retry exhaustion in app/models/concerns/public_id.rb
- [X] T011 [P] Add model tests for game public_id generation/format/retry in test/models/game_test.rb
- [X] T012 [P] Add model tests for team public_id generation/format/retry in test/models/team_test.rb
- [X] T013 Add migration/backfill verification tests in test/integration/public_ids_backfill_test.rb
- [X] T052 Add explicit cross-model collision test (Game segment already used by Team) in test/models/game_test.rb

**Checkpoint**: Database and model foundation is ready; user stories can now proceed.

---

## Phase 3: User Story 1 - Acceder a une partie via identifiant public (Priority: P1) 🎯 MVP

**Goal**: Public game URLs use `gm_<segment>` and never expose numeric IDs.

**Independent Test**: Create a game, open `/games/:public_id`, confirm URL uses `gm_` and numeric `/games/:id` returns 404.

### Tests for User Story 1

- [X] T014 [P] [US1] Add show-route success test by game public_id in test/controllers/games_controller_test.rb
- [X] T015 [P] [US1] Add 404 test for numeric game id on public endpoint in test/controllers/games_controller_test.rb
- [X] T016 [P] [US1] Add malformed game public_id 404 test in test/integration/public_ids_routing_test.rb
- [X] T046 [P] [US1] Add no-leak assertions (generic 404 body, no internal details) for invalid game public_id in test/controllers/games_controller_test.rb

### Implementation for User Story 1

- [X] T017 [US1] Resolve game resources by public_id in app/controllers/games_controller.rb
- [X] T018 [US1] Return 404 without redirect for invalid/numeric game ids in app/controllers/games_controller.rb
- [X] T019 [US1] Ensure game URL helpers emit public_id via to_param in app/models/game.rb
- [X] T020 [US1] Update game links rendered from team pages to public URLs in app/views/teams/show.html.erb
- [X] T021 [US1] Update game-specific view links to remain public-id based in app/views/games/show.html.erb

**Checkpoint**: US1 is fully functional and testable independently.

---

## Phase 4: User Story 2 - Acceder a une equipe via identifiant public (Priority: P2)

**Goal**: Public team URLs use `tm_<segment>` and nested team game routes resolve by team public_id.

**Independent Test**: Create a team, open `/teams/:public_id`, confirm `tm_` URL and numeric `/teams/:id` returns 404.

### Tests for User Story 2

- [X] T022 [P] [US2] Add show-route success test by team public_id in test/controllers/teams_controller_test.rb
- [X] T023 [P] [US2] Add 404 test for numeric team id on public endpoint in test/controllers/teams_controller_test.rb
- [X] T024 [P] [US2] Add nested `/teams/:public_id/games` resolution test in test/controllers/games_controller_test.rb
- [X] T047 [P] [US2] Add no-leak assertions (generic 404 body, no internal details) for invalid team public_id in test/controllers/teams_controller_test.rb

### Implementation for User Story 2

- [X] T025 [US2] Resolve team resources by public_id in app/controllers/teams_controller.rb
- [X] T026 [US2] Resolve parent team by public_id for nested games routes in app/controllers/games_controller.rb
- [X] T027 [US2] Return 404 without redirect for invalid/numeric team ids in app/controllers/teams_controller.rb
- [X] T028 [US2] Ensure team URL helpers emit public_id via to_param in app/models/team.rb
- [X] T029 [US2] Update team and nested game route params to semantic public-id names in config/routes.rb
- [X] T030 [US2] Update team links in index/home views to public URLs in app/views/teams/index.html.erb

**Checkpoint**: US1 and US2 both work independently with public IDs.

---

## Phase 5: User Story 3 - Compatibilite des flux existants avec identifiants publics (Priority: P3)

**Goal**: Existing game/team journeys remain functional after moving to public IDs.

**Independent Test**: Run existing public flows (team page, game page, proposal/guess/results navigation) using public IDs only.

### Tests for User Story 3

- [X] T031 [P] [US3] Add end-to-end public-id navigation test for team->game->proposal flow in test/integration/public_ids_routing_test.rb
- [X] T032 [P] [US3] Add end-to-end public-id navigation test for guessing/results flow in test/integration/public_ids_routing_test.rb
- [X] T033 [P] [US3] Add regression test ensuring no generated public link contains numeric id in test/integration/public_ids_routing_test.rb

### Implementation for User Story 3

- [X] T034 [US3] Resolve nested proposal game lookup by public_id in app/controllers/proposals_controller.rb
- [X] T035 [US3] Resolve nested guess game lookup by public_id in app/controllers/guesses_controller.rb
- [X] T036 [US3] Resolve nested results game lookup by public_id in app/controllers/results_controller.rb
- [X] T037 [US3] Update invitation and membership redirects to team public URLs in app/controllers/invitations_controller.rb
- [X] T038 [US3] Update membership leave/destroy redirects to team public URLs in app/controllers/memberships_controller.rb
- [X] T039 [US3] Update proposal view/forms to pass public route params in app/views/proposals/new.html.erb
- [X] T040 [US3] Update guess view/forms to pass public route params in app/views/guesses/new.html.erb
- [X] T041 [US3] Update results view links to pass public route params in app/views/results/show.html.erb

**Checkpoint**: All user stories are functional without exposing numeric IDs.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final hardening, docs, and verification.

- [X] T042 [P] Document migration/backfill rollout and rollback in README.md
- [X] T043 [P] Update feature quickstart validation commands in specs/017-public-url-ids/quickstart.md
- [X] T044 Run full feature validation suite and record outcomes in specs/017-public-url-ids/quickstart.md
- [X] T045 Add operational note for collision-exhaustion logs in docs/index.html
- [X] T048 [P] Add performance benchmark task for public_id lookups (p95 target) in tmp/benchmark_public_id_lookup.rb
- [X] T049 [P] Add N+1 regression check for team/game pages in test/integration/public_ids_routing_test.rb
- [X] T050 [P] Add UX/interaction review checklist for updated links and flows in specs/017-public-url-ids/checklists/ux-public-id-flows.md
- [X] T051 Define and run SC-005 test protocol (>=95% success) and record evidence in specs/017-public-url-ids/checklists/sc005-validation.md
- [X] T053 Add CI verification step for public_id performance budget (or documented non-feasibility) in .github/workflows/ci.yml

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1): starts immediately.
- Foundational (Phase 2): depends on Phase 1; blocks all user stories.
- User Stories (Phase 3+): depend on Phase 2 completion.
- Polish (Phase 6): depends on all targeted user stories.

### User Story Dependencies

- US1 (P1): starts after Foundational; no dependency on US2/US3.
- US2 (P2): starts after Foundational; independent of US1, but shares common route patterns.
- US3 (P3): starts after Foundational and should be run after US1/US2 to validate compatibility flows.

### Within Each User Story

- Write tests first and verify failure.
- Implement controller/model/view changes.
- Re-run targeted tests before moving on.

## Parallel Opportunities

- Foundational parallel tasks: T008 and T009; T011 and T012.
- US1 parallel tests: T014, T015, T016.
- US2 parallel tests: T022, T023, T024.
- US3 parallel tests: T031, T032, T033.
- Polish parallel docs tasks: T042 and T043.
- Performance parallel tasks: T048 and T053.

## Parallel Example: User Story 1

- Run T014, T015, T016 together in separate edits/tests.
- Run T020 and T021 in parallel once T017-T019 are merged.

## Parallel Example: User Story 2

- Run T022, T023, T024 together.
- Run T025 and T026 in parallel, then finish T029 and T030.

## Parallel Example: User Story 3

- Run T034, T035, T036 in parallel on separate controllers.
- Run T037 and T038 in parallel, then complete T039, T040 and T041.

## Implementation Strategy

### MVP First (US1)

1. Complete Phase 1 and Phase 2.
2. Deliver Phase 3 (US1).
3. Validate US1 independently and demo/deploy MVP.

### Incremental Delivery

1. Foundation complete.
2. Add US1 and validate.
3. Add US2 and validate.
4. Add US3 compatibility and validate.
5. Finalize polish tasks.

### Two-Deployment Rollout Alignment

1. Deployment A: schema + concern + backfill (T004-T013).
2. Deployment B: public-id route resolution and strict 404 behavior (T014-T041).
