# Tasks: Autonomie des membres d'équipe

**Input**: Design documents from `/specs/012-team-member-autonomy/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/, quickstart.md

**Tests**: Tests are required for every changed behavior in this feature (permissions, transitions, UI visibility, concurrency).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (`[US1]`, `[US2]`, `[US3]`)
- Every task includes an exact file path

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare test data and shared messages for the feature.

- [X] T001 Create organizer/member/non-member fixture coverage in test/fixtures/users.yml
- [X] T002 [P] Add team membership fixture scenarios for permission tests in test/fixtures/memberships.yml
- [X] T003 [P] Add feature flash/error message keys for permission and conflict feedback in config/locales/fr.yml

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core permission and transition foundations required before user stories.

**⚠️ CRITICAL**: No user story implementation starts before this phase is complete.

- [X] T004 Add shared authorization helpers for member and organizer gates in app/controllers/application_controller.rb
- [X] T005 Refactor game authorization entry points to use shared helpers in app/controllers/games_controller.rb
- [X] T006 [P] Refactor membership organizer-only guard flow to use shared helpers in app/controllers/memberships_controller.rb
- [X] T007 Add explicit concurrent-transition conflict signaling in app/models/game.rb
- [X] T008 [P] Align transition contract on single HTML redirect strategy with explicit conflict message examples in specs/012-team-member-autonomy/contracts/team-member-autonomy.openapi.yaml

**Checkpoint**: Foundation ready — user stories can proceed.

---

## Phase 3: User Story 1 - Continuer une partie sans organisateur (Priority: P1) 🎯 MVP

**Goal**: Any team member (including organizer) can launch/start guessing/finish a game in valid states.

**Independent Test**: Connect as non-organizer member, run launch → guessing → finish, and verify final game state is reached.

### Tests for User Story 1

- [X] T009 [P] [US1] Add controller tests for member-allowed progression actions in test/controllers/games_controller_test.rb
- [X] T010 [P] [US1] Add model tests for transition validity and conflict signaling in test/models/game_test.rb
- [X] T011 [US1] Add system test for end-to-end member progression flow in test/system/teams_test.rb

### Implementation for User Story 1

- [X] T012 [US1] Allow team members to access progression actions (create/start_guessing/finish) in app/controllers/games_controller.rb
- [X] T013 [US1] Implement conflict-aware transition handling with explicit user feedback in app/controllers/games_controller.rb
- [X] T014 [US1] Enforce invalid-state and concurrency safeguards for manual transitions in app/models/game.rb
- [X] T015 [US1] Ensure non-member direct URL progression attempts are rejected with redirect feedback in app/controllers/games_controller.rb
- [X] T016 [US1] Show launch/progression controls to authorized team members in app/views/teams/show.html.erb
- [X] T017 [US1] Show progression controls to authorized team members in app/views/games/_collecting.html.erb
- [X] T018 [US1] Show finishing controls to authorized team members in app/views/games/_guessing.html.erb

**Checkpoint**: User Story 1 is independently functional and testable.

---

## Phase 4: User Story 2 - Protéger les actions réservées à l'organisateur (Priority: P1)

**Goal**: Cancel game and membership management remain strictly organizer-only.

**Independent Test**: Try cancel/add/remove as member (must fail), then as organizer (must succeed).

### Tests for User Story 2

- [X] T019 [P] [US2] Add controller tests for organizer-only game cancellation in test/controllers/games_controller_test.rb
- [X] T020 [P] [US2] Add controller tests for organizer-only membership create/destroy in test/controllers/memberships_controller_test.rb
- [X] T021 [US2] Add system test for organizer-only governance actions in test/system/teams_test.rb

### Implementation for User Story 2

- [X] T022 [US2] Preserve organizer-only cancellation guard with explicit denial message path in app/controllers/games_controller.rb
- [X] T023 [US2] Preserve organizer-only membership create/destroy guards with explicit denial message path in app/controllers/memberships_controller.rb
- [X] T024 [US2] Keep organizer non-removability invariant enforcement in app/controllers/memberships_controller.rb
- [X] T025 [US2] Restrict governance controls visibility to organizer in app/views/teams/show.html.erb

**Checkpoint**: User Stories 1 and 2 both work independently.

---

## Phase 5: User Story 3 - Comprendre clairement ses permissions (Priority: P2)

**Goal**: UI clearly reflects what each role can do by hiding unauthorized actions.

**Independent Test**: Compare same game/team screens for member vs organizer and verify visible actions match policy.

### Tests for User Story 3

- [X] T026 [US3] Add system test for role-based game action visibility in test/system/teams_test.rb
- [X] T027 [US3] Add system test for role-based team management visibility in test/system/teams_test.rb

### Implementation for User Story 3

- [X] T028 [US3] Hide unauthorized game actions for current role in app/views/games/_collecting.html.erb
- [X] T029 [US3] Hide unauthorized guessing-phase actions for current role in app/views/games/_guessing.html.erb
- [X] T030 [US3] Hide unauthorized membership management actions for current role in app/views/teams/show.html.erb
- [X] T031 [US3] Standardize permission-denied and conflict feedback copy in config/locales/fr.yml

**Checkpoint**: All user stories are independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation, documentation, and release notes.

- [X] T032 [P] Update feature summary and role permissions in README.md
- [X] T033 Update changelog with v1.2.3 entry for feature #012 in README.md
- [X] T034 [P] Run full quality gates and document command outcomes in specs/012-team-member-autonomy/quickstart.md
- [X] T035 Run quickstart manual validation scenarios and record results in specs/012-team-member-autonomy/quickstart.md
- [X] T036 Add SC-003 timed usability protocol and measured results section in specs/012-team-member-autonomy/quickstart.md
- [X] T037 Add accessibility review checklist/results (keyboard, contrast, readable feedback) in specs/012-team-member-autonomy/quickstart.md
- [X] T038 Add CI verification step (or explicit non-feasibility rationale) for performance budget checks in specs/012-team-member-autonomy/quickstart.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies.
- **Phase 2 (Foundational)**: Depends on Phase 1 and blocks all user stories.
- **Phase 3+ (User Stories)**: Depend on Phase 2 completion.
- **Phase 6 (Polish)**: Depends on completion of desired user stories.

### User Story Dependencies

- **US1 (P1)**: Starts after Phase 2; no dependency on other stories.
- **US2 (P1)**: Starts after Phase 2; independent from US1 functional delivery.
- **US3 (P2)**: Starts after Phase 2; should be validated after US1+US2 behavior is in place.

### Within Each User Story

- Tests first, then implementation.
- Controller/domain authorization before UI visibility adjustments.
- Story must pass its independent test before moving on.

---

## Parallel Opportunities

- **Setup**: T002 and T003 can run in parallel.
- **Foundational**: T006 and T008 can run in parallel after T004/T005 kickoff.
- **US1**: T009 and T010 can run in parallel; T016/T017/T018 can run in parallel after T012.
- **US2**: T019 and T020 can run in parallel; T022 and T023 can run in parallel.
- **US3**: T026 puis T027 (même fichier de test); T028/T029/T030 peuvent être parallélisées.
- **Polish**: T032 et T034 peuvent être parallélisées; T036/T037/T038 se font en séquence dans quickstart.md.

---

## Parallel Example: User Story 1

```bash
# Parallel test work (US1)
T009 test/controllers/games_controller_test.rb
T010 test/models/game_test.rb

# Parallel UI work after authorization core is done
T016 app/views/teams/show.html.erb
T017 app/views/games/_collecting.html.erb
T018 app/views/games/_guessing.html.erb
```

## Parallel Example: User Story 2

```bash
# Parallel policy tests (US2)
T019 test/controllers/games_controller_test.rb
T020 test/controllers/memberships_controller_test.rb

# Parallel guard implementations
T022 app/controllers/games_controller.rb
T023 app/controllers/memberships_controller.rb
```

## Parallel Example: User Story 3

```bash
# Parallel role-based UI updates
T028 app/views/games/_collecting.html.erb
T029 app/views/games/_guessing.html.erb
T030 app/views/teams/show.html.erb
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 + Phase 2.
2. Complete Phase 3 (US1).
3. Validate US1 independent test.
4. Demo/deploy MVP.

### Incremental Delivery

1. Deliver US1 (MVP progression autonomy).
2. Deliver US2 (governance protection hardening).
3. Deliver US3 (UI clarity and role visibility).
4. Finish with docs + release notes in Phase 6.

### Parallel Team Strategy

1. Team aligns on Setup + Foundational tasks.
2. Then split by story:
   - Dev A: US1
   - Dev B: US2
   - Dev C: US3
3. Merge at checkpoints and execute Phase 6 together.

---

## Notes

- `[P]` tasks are file-independent and parallel-safe.
- All tasks follow checklist format with ID, optional `[P]`, optional `[USx]`, and exact file path.
- README update + changelog v1.2.3 are mandatory deliverables in this plan.
