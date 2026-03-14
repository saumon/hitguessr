# Tasks: Team-Scoped Game Numbering

**Input**: Design documents from `/specs/018-team-game-numbering/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/, quickstart.md

**Tests**: Tests are REQUIRED for changed behavior in this feature (creation flow, backfill, display consistency, and stability rules).

**Organization**: Tasks are grouped by user story so each story can be implemented and tested independently.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare feature scaffolding and validation placeholders.

- [X] T001 Create feature integration test scaffold in test/integration/team_game_numbering_flow_test.rb
- [X] T002 Create migration verification scaffold in test/integration/team_game_numbering_backfill_test.rb
- [X] T003 [P] Add benchmark scaffold for create-flow latency in tmp/benchmark_team_game_numbering_create.rb

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core schema/model behavior required before user-story work.

**⚠️ CRITICAL**: No user story implementation starts before this phase is complete.

- [X] T004 Create migration to add nullable team_game_number column in db/migrate/*_add_team_game_number_to_games.rb
- [X] T005 Create migration to backfill team_game_number per team ordered by created_at/id in db/migrate/*_backfill_team_game_numbers.rb
- [X] T006 Create migration to enforce NOT NULL and unique index (team_id, team_game_number) in db/migrate/*_enforce_team_game_number_constraints.rb
- [X] T007 Implement deterministic allocator and retry-on-collision helper in app/models/game.rb
- [X] T008 Add model validations for positivity and scoped uniqueness in app/models/game.rb
- [X] T009 Add team_id immutability validation after create in app/models/game.rb
- [X] T010 [P] Add model tests for allocation sequence and uniqueness in test/models/game_test.rb
- [X] T011 [P] Add model tests for team_id immutability and stable numbering on update in test/models/game_test.rb
- [X] T012 Add migration/backfill verification tests for historical games in test/integration/team_game_numbering_backfill_test.rb

**Checkpoint**: Database and model foundation is ready; user stories can proceed.

---

## Phase 3: User Story 1 - Voir une numérotation continue des parties d'équipe (Priority: P1) 🎯 MVP

**Goal**: Chaque équipe voit ses parties numérotées 1, 2, 3... sans trous causés par une numérotation globale.

**Independent Test**: Créer plusieurs parties pour une équipe, créer/supprimer des parties dans une autre équipe, puis vérifier que la séquence locale reste continue et indépendante.

### Tests for User Story 1

- [X] T013 [P] [US1] Add controller test for first game number = 1 on team create flow in test/controllers/games_controller_test.rb
- [X] T014 [P] [US1] Add controller test for incremental team numbering on successive creates in test/controllers/games_controller_test.rb
- [X] T015 [P] [US1] Add integration test for independent numbering across two teams in test/integration/team_game_numbering_flow_test.rb
- [X] T016 [P] [US1] Add integration test ensuring deletion does not renumber existing games in test/integration/team_game_numbering_flow_test.rb

### Implementation for User Story 1

- [X] T017 [US1] Assign next team_game_number inside locked create flow in app/controllers/games_controller.rb
- [X] T018 [US1] Wire short bounded retry on unique collision during game creation in app/controllers/games_controller.rb
- [X] T019 [US1] Expose helper method for next number computation scoped by team in app/models/game.rb
- [X] T020 [US1] Display team_game_number instead of id in team game list UI in app/views/games/index.html.erb
- [X] T021 [US1] Display team_game_number for recent games and active game link label in app/views/teams/show.html.erb

**Checkpoint**: US1 is fully functional and testable independently.

---

## Phase 4: User Story 2 - Conserver des numéros stables dans le temps (Priority: P2)

**Goal**: Le numéro d'une partie existante reste inchangé dans le temps et ne peut pas être invalidé par un changement d'équipe.

**Independent Test**: Relever des numéros existants, effectuer des mises à jour et créations hors équipe, puis vérifier l'immutabilité des numéros et le rejet de changement de team.

### Tests for User Story 2

- [X] T022 [P] [US2] Add model test ensuring team_game_number remains unchanged after non-team updates in test/models/game_test.rb
- [X] T023 [P] [US2] Add model test rejecting team_id reassignment after create in test/models/game_test.rb
- [X] T024 [P] [US2] Add integration test ensuring existing game numbers stay stable when other teams create games in test/integration/team_game_numbering_flow_test.rb

### Implementation for User Story 2

- [X] T025 [US2] Prevent team_id mutation with explicit validation error in app/models/game.rb
- [X] T026 [US2] Ensure destroy flow preserves remaining team_game_number values and next allocation uses max+1 in app/models/game.rb
- [X] T027 [US2] Add clear localized validation message for immutable team assignment in config/locales/fr.yml
- [X] T028 [US2] Reflect stable team game number in results header instead of global id in app/views/results/show.html.erb

**Checkpoint**: US1 and US2 both work independently with stable numbering behavior.

---

## Phase 5: User Story 3 - Afficher un numéro cohérent sur les vues de parties (Priority: P3)

**Goal**: Tous les écrans qui affichent un numéro de partie utilisent la même valeur team_game_number.

**Independent Test**: Ouvrir les vues team list, game show et results d'une même partie et vérifier l'identité du numéro affiché.

### Tests for User Story 3

- [X] T029 [P] [US3] Add controller/view test asserting game show title uses team_game_number in test/controllers/games_controller_test.rb
- [X] T030 [P] [US3] Add integration test asserting consistency of displayed number across team show, game show, and results pages in test/integration/team_game_numbering_flow_test.rb
- [X] T031 [P] [US3] Add regression test preventing fallback to game.id in main game-number labels in test/integration/team_game_numbering_flow_test.rb
- [X] T041 [P] [US3] Add visual review checklist and evidence for updated game-number screens in specs/018-team-game-numbering/quickstart.md

### Implementation for User Story 3

- [X] T032 [US3] Replace game.id with team_game_number in game detail header in app/views/games/show.html.erb
- [X] T033 [US3] Update any remaining game number badge/label in team page to use team_game_number in app/views/teams/show.html.erb
- [X] T034 [US3] Ensure presenter/helper-level formatting always consumes team_game_number in app/helpers/application_helper.rb
- [X] T035 [US3] Align contract examples and field descriptions with team_game_number display behavior in specs/018-team-game-numbering/contracts/team-game-numbering.openapi.yaml
- [X] T042 [US3] Add integration-level query count guard ensuring no extra SQL for team numbering render in test/integration/team_game_numbering_flow_test.rb

**Checkpoint**: All user stories are independently functional with coherent UI numbering.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final hardening, docs, and end-to-end validation.

- [X] T036 [P] Document rollout and rollback steps for backfill + constraint enforcement in specs/018-team-game-numbering/quickstart.md
- [X] T037 [P] Add ops verification commands and expected outputs for duplicate/missing checks in specs/018-team-game-numbering/quickstart.md
- [X] T038 Run focused test suites and capture pass/fail summary in specs/018-team-game-numbering/quickstart.md
- [X] T039 Run full test suite and capture final validation result in specs/018-team-game-numbering/quickstart.md
- [X] T040 [P] Execute benchmark and record p95 create latency outcome in tmp/benchmark_team_game_numbering_create.rb
- [X] T043 [P] Execute concurrent-create stress check and record retry success rate (target >= 99.9%) in tmp/benchmark_team_game_numbering_create.rb

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1): starts immediately.
- Foundational (Phase 2): depends on Setup; blocks all user stories.
- User Stories (Phase 3+): all depend on Foundational completion.
- Polish (Phase 6): depends on target user stories being complete.

### User Story Dependencies

- US1 (P1): starts after Foundational; no dependency on US2/US3.
- US2 (P2): starts after Foundational and depends on allocator behavior from US1 paths.
- US3 (P3): starts after Foundational; should be completed after US1 implementation to validate displayed values.

### Story Completion Order

- US1 → US2 → US3

### Within Each User Story

- Write tests first and verify they fail.
- Implement model/controller logic.
- Update views and helper formatting.
- Re-run targeted tests before closing the story.

## Parallel Opportunities

- Foundational: T010 and T011 can run in parallel.
- US1 tests: T013, T014, T015, and T016 can run in parallel.
- US2 tests: T022, T023, and T024 can run in parallel.
- US3 tests/docs: T029, T030, T031, and T041 can run in parallel.
- Polish docs/ops tasks: T036, T037, T040, and T043 can run in parallel.

## Parallel Example: User Story 1

- Parallel test batch: T013 + T014 + T015 + T016.
- Parallel UI updates after core allocator is in place: T020 + T021.

## Parallel Example: User Story 2

- Parallel test batch: T022 + T023 + T024.
- Parallel implementation once model guard exists: T027 + T028.

## Parallel Example: User Story 3

- Parallel test/doc batch: T029 + T030 + T031 + T041.
- Parallel implementation batch: T033 + T034 + T035 + T042.

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1 and Phase 2.
2. Deliver Phase 3 (US1).
3. Validate US1 independently and demo/deploy MVP.

### Incremental Delivery

1. Foundation complete.
2. Add US1 and validate.
3. Add US2 and validate.
4. Add US3 and validate.
5. Finish polish and full-suite verification.

### Parallel Team Strategy

1. Team completes Setup + Foundational together.
2. Once Foundational is complete:
   - Developer A: US1 implementation.
   - Developer B: US2 stability checks.
   - Developer C: US3 display consistency.
3. Merge by story checkpoints with independent test evidence.
