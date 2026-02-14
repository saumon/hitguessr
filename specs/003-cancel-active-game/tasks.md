# Tasks: Annulation d'une partie active

**Input**: Design documents from `/specs/003-cancel-active-game/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅

**Tests**: Tests are REQUIRED for any new or changed behavior (controller tests + system test).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- File paths relative to repository root

---

## Phase 1: Setup

**Purpose**: Route configuration and basic controller setup

- [X] T001 Add `:destroy` action to `resources :games` in `config/routes.rb`
- [X] T002 Add `set_game` and authorization callbacks for `destroy` in `app/controllers/games_controller.rb`

---

## Phase 2: Foundational

**Purpose**: Core destroy infrastructure - MUST complete before user story work

- [X] T003 Add `can_cancel?` validation method to `Game` model in `app/models/game.rb` (returns true only if game is active: `collecting` or `guessing`)
- [X] T004 Add `destroy` action skeleton in `app/controllers/games_controller.rb` with transaction wrapper and redirect logic

**Checkpoint**: Foundation ready - user story implementation can begin

---

## Phase 3: User Story 1 - Annulation par l'organisateur (Priority: P1) 🎯 MVP

**Goal**: L'organisateur peut annuler définitivement sa partie active avec confirmation

**Independent Test**: Se connecter comme organisateur → cliquer "Annuler" → confirmer → partie supprimée

### Tests for User Story 1

- [X] T005 [P] [US1] Controller test: `destroy` succeeds for organizer in `test/controllers/games_controller_test.rb`
- [X] T006 [P] [US1] Controller test: `destroy` redirects with flash notice in `test/controllers/games_controller_test.rb`
- [X] T007 [P] [US1] Controller test: cascade deletes proposals and guesses in `test/controllers/games_controller_test.rb`
- [X] T007b [P] [US1] Controller test: verify transaction rollback on destroy failure (atomicity per FR-006) in `test/controllers/games_controller_test.rb`

### Implementation for User Story 1

- [X] T008 [US1] Implement full `destroy` action logic in `app/controllers/games_controller.rb` (find game, check can_cancel?, destroy in transaction, redirect with notice)
- [X] T009 [US1] Add "Annuler la partie" button with `data-turbo-confirm` to `app/views/games/show.html.erb` (visible only to organizer, only for active games)
- [X] T010 [US1] Add French confirmation message: "Voulez-vous vraiment annuler cette partie ? Cette action est irréversible."
- [X] T011 [US1] Add flash messages to locale files `config/locales/fr.yml` ("Partie annulée avec succès.")

### System Test for User Story 1

- [X] T012 [US1] System test: organizer cancels active game with confirmation in `test/system/cancel_game_test.rb`

**Checkpoint**: Organizer can cancel games with confirmation - MVP complete

---

## Phase 4: User Story 2 - Tentative non autorisée (Priority: P2)

**Goal**: Les utilisateurs non propriétaires ne peuvent pas annuler une partie

**Independent Test**: Se connecter comme membre (non organisateur) → tenter DELETE → 403

### Tests for User Story 2

- [X] T013 [P] [US2] Controller test: `destroy` returns 403/redirect for non-organizer in `test/controllers/games_controller_test.rb`
- [X] T014 [P] [US2] Controller test: `destroy` returns 403/redirect for non-member in `test/controllers/games_controller_test.rb`

### Implementation for User Story 2

- [X] T015 [US2] Ensure `authorize_organizer_for_game!` callback is applied to `destroy` action in `app/controllers/games_controller.rb`
- [X] T016 [US2] Ensure cancel button is hidden in view when user is not organizer in `app/views/games/show.html.erb`

**Checkpoint**: Non-organizers cannot cancel games

---

## Phase 5: User Story 3 - Partie terminée/introuvable (Priority: P3)

**Goal**: Gérer les cas limites (partie terminée, partie inexistante)

**Independent Test**: Tenter d'annuler une partie `finished` ou inexistante → erreur 422/404

### Tests for User Story 3

- [X] T017 [P] [US3] Controller test: `destroy` returns 422 for finished game in `test/controllers/games_controller_test.rb`
- [X] T018 [P] [US3] Controller test: `destroy` returns 404 for non-existent game in `test/controllers/games_controller_test.rb`

### Implementation for User Story 3

- [X] T019 [US3] Add guard clause in `destroy` action: if `!@game.can_cancel?`, redirect with alert "Impossible d'annuler une partie terminée."
- [X] T020 [US3] Hide cancel button for finished games in `app/views/games/show.html.erb`

**Checkpoint**: Edge cases handled gracefully

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation, documentation, and quality checks

- [X] T021 [P] Run RuboCop and fix any style violations
- [X] T022 [P] Run Brakeman security check
- [X] T023 [P] Update `specs/003-cancel-active-game/quickstart.md` with actual manual test results
- [X] T024 Run full test suite: `bin/rails test && bin/rails test:system`
- [X] T025 Manual smoke test per quickstart.md scenarios

---

## Dependencies & Execution Order

### Phase Dependencies

```text
Phase 1 (Setup)
    ↓
Phase 2 (Foundational)
    ↓
┌───────────────────┬───────────────────┬───────────────────┐
│  Phase 3 (US1)    │  Phase 4 (US2)    │  Phase 5 (US3)    │
│  P1 - MVP 🎯      │  P2               │  P3               │
└───────────────────┴───────────────────┴───────────────────┘
    ↓ (all complete)
Phase 6 (Polish)
```

### User Story Dependencies

| Story | Depends On | Can Parallelize With |
| ----- | --------- | ------------------- |
| US1 (P1) | Phase 2 | - |
| US2 (P2) | Phase 2, T008 (destroy action exists) | US3 |
| US3 (P3) | Phase 2, T008 (destroy action exists) | US2 |

### Parallel Execution Examples

**Team of 1** (Sequential by priority):

```text
T001 → T002 → T003 → T004 → T005-T007 (parallel) → T008 → T009-T011 (parallel) → T012 → T013-T014 (parallel) → T015-T016 → T017-T018 (parallel) → T019-T020 → T021-T024
```

**Team of 2** (User stories in parallel after foundation):

```text
Dev A: T001-T004 → US1 (T005-T012) → Polish (T021-T025)
Dev B: (wait for T004) → US2 (T013-T016) + US3 (T017-T020)
```

---

## Implementation Strategy

### MVP Scope (Recommended first delivery)

Implement **Phase 1 + Phase 2 + User Story 1** only:

- Tasks: T001-T012
- Delivers: Core cancellation feature for organizers
- Testable: Organizer can cancel active games with confirmation

### Full Feature

All phases (T001-T025):

- Authorization checks (US2)
- Edge case handling (US3)
- Polish and validation

---

## Summary

| Metric | Value |
| ------ | ----- |
| Total tasks | 25 |
| Setup tasks | 2 |
| Foundational tasks | 2 |
| US1 (P1 MVP) tasks | 8 |
| US2 (P2) tasks | 4 |
| US3 (P3) tasks | 4 |
| Polish tasks | 5 |
| Parallel opportunities | 12 tasks marked [P] |
