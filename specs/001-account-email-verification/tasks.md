# Tasks: Activation de compte par email

**Input**: Design documents from `/specs/001-account-email-verification/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/, quickstart.md

**Tests**: Tests are REQUIRED for all changed behaviors in this feature (registration confirmation, sign-in blocking, resend, toggle behavior, and security edge cases).

**Organization**: Tasks are grouped by user story so each story can be implemented and tested independently.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare feature scaffolding and test entry points.

- [X] T001 Create feature integration test scaffold in test/integration/account_email_confirmation_flow_test.rb
- [X] T002 Create toggle behavior integration test scaffold in test/integration/account_email_confirmation_toggle_test.rb
- [X] T003 [P] Create resend behavior integration test scaffold in test/integration/account_email_confirmation_resend_test.rb
- [X] T004 [P] Create user confirmable model test scaffold in test/models/user_confirmable_test.rb

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core auth/config/schema prerequisites required before any user story work.

**⚠️ CRITICAL**: No user story implementation starts before this phase is complete.

- [X] T005 Create migration adding Devise confirmable columns/indexes on users in db/migrate/*_add_confirmable_to_users.rb
- [X] T006 Add migration backfill to mark existing users as confirmed in db/migrate/*_backfill_users_confirmed_at.rb
- [X] T007 Enable Devise confirmable module on User model in app/models/user.rb
- [X] T008 Configure confirmation token validity (24h) in config/initializers/devise.rb
- [X] T009 Add feature-toggle resolver (ENV then credentials fallback) in config/mailer_settings.rb
- [X] T010 Configure environment defaults for confirmation toggle in config/environments/development.rb
- [X] T011 [P] Configure environment defaults for confirmation toggle in config/environments/test.rb
- [X] T012 [P] Configure environment defaults for confirmation toggle in config/environments/production.rb
- [X] T013 Add custom Devise session controller hook for toggle-aware confirmation enforcement in app/controllers/users/sessions_controller.rb
- [X] T014 Add custom Devise confirmation controller base for resend/feedback policy in app/controllers/users/confirmations_controller.rb
- [X] T015 Wire custom Devise controllers in routes mapping in config/routes.rb
- [X] T016 [P] Add i18n keys for confirmation-required and generic resend feedback in config/locales/devise.en.yml
- [X] T017 [P] Add i18n keys for confirmation-required and generic resend feedback in config/locales/devise.fr.yml
- [X] T018 Add foundational model tests for confirmable fields and backfill expectations in test/models/user_confirmable_test.rb
- [X] T019 Add foundational integration tests for toggle precedence (ENV over credentials) in test/integration/account_email_confirmation_toggle_test.rb

**Checkpoint**: Schema, Devise config, toggle policy, and controller wiring are ready; user stories can start.

---

## Phase 3: User Story 1 - Confirmer son compte après inscription (Priority: P1) 🎯 MVP

**Goal**: A newly registered user receives a confirmation email and can activate the account via valid confirmation link.

**Independent Test**: Create account with valid email, verify confirmation email delivery, click activation link, verify account is activated with explicit success message.

### Tests for User Story 1

- [X] T020 [P] [US1] Add integration test for confirmation email sent on sign-up when toggle enabled in test/integration/account_email_confirmation_flow_test.rb
- [X] T021 [P] [US1] Add integration test for successful account activation via valid token in test/integration/account_email_confirmation_flow_test.rb
- [X] T022 [P] [US1] Add integration test for invalid/expired confirmation token rejection in test/integration/account_email_confirmation_flow_test.rb
- [X] T023 [P] [US1] Add model test for confirm_within 24h behavior in test/models/user_confirmable_test.rb

### Implementation for User Story 1

- [X] T024 [US1] Implement toggle-aware sign-up confirmation instruction sending behavior in app/models/user.rb
- [X] T025 [US1] Ensure activation success/failure feedback is explicit and localized in app/controllers/users/confirmations_controller.rb
- [X] T026 [US1] Preserve and validate existing confirmation email template/link rendering in app/views/devise/mailer/confirmation_instructions.html.erb
- [X] T027 [US1] Align contract notes for sign-up and confirm-token success/failure behavior in specs/001-account-email-verification/contracts/email-confirmation.openapi.yaml
- [X] T055 [P] [US1] Add model/integration test for case-insensitive email uniqueness (e.g., <User@x.com> vs <user@x.com>) in test/models/user_confirmable_test.rb
- [X] T056 [US1] Ensure case-insensitive uniqueness enforcement is explicit at model/db level in app/models/user.rb and db/migrate/*_add_confirmable_to_users.rb

**Checkpoint**: US1 is fully functional and independently testable.

---

## Phase 4: User Story 2 - Bloquer la connexion avant activation (Priority: P1)

**Goal**: Unconfirmed users are refused at sign-in with clear activation-required feedback; confirmed users sign in normally.

**Independent Test**: Create unconfirmed account and attempt sign-in with valid credentials (denied with activation-required message), then confirm account and verify next sign-in succeeds.

### Tests for User Story 2

- [X] T028 [P] [US2] Add integration test denying sign-in for unconfirmed user when toggle enabled in test/integration/account_email_confirmation_flow_test.rb
- [X] T029 [P] [US2] Add integration test allowing sign-in after confirmation in test/integration/account_email_confirmation_flow_test.rb
- [X] T030 [P] [US2] Add integration test for toggle disabled mode allowing sign-in without confirmation in test/integration/account_email_confirmation_toggle_test.rb

### Implementation for User Story 2

- [X] T031 [US2] Implement sign-in blocking logic for unconfirmed users when feature is enabled in app/controllers/users/sessions_controller.rb
- [X] T032 [US2] Implement toggle bypass path for development/local auth flow in app/controllers/users/sessions_controller.rb
- [X] T033 [US2] Add localized activation-required messaging in config/locales/devise.en.yml
- [X] T034 [US2] Add localized activation-required messaging in config/locales/devise.fr.yml
- [X] T053 [P] [US2] Add integration test ensuring failed sign-in of unconfirmed user does not trigger automatic resend in test/integration/account_email_confirmation_flow_test.rb
- [X] T054 [US2] Enforce no automatic resend side effect on failed sign-in path in app/controllers/users/sessions_controller.rb

**Checkpoint**: US2 is fully functional and independently testable.

---

## Phase 5: User Story 3 - Re-demander un email de confirmation (Priority: P2)

**Goal**: Unconfirmed users can request a new confirmation email safely, with generic anti-enumeration responses and resend throttle.

**Independent Test**: Request resend for unconfirmed account and confirm a new email is sent; unknown email gets identical generic response; repeated resend within 5 minutes is throttled; only latest token remains valid.

### Tests for User Story 3

- [X] T035 [P] [US3] Add integration test for resend confirmation on unconfirmed account in test/integration/account_email_confirmation_resend_test.rb
- [X] T036 [P] [US3] Add integration test for generic response on unknown email in test/integration/account_email_confirmation_resend_test.rb
- [X] T037 [P] [US3] Add integration test for resend throttle (5-minute cooldown) in test/integration/account_email_confirmation_resend_test.rb
- [X] T038 [P] [US3] Add integration test ensuring latest confirmation token wins after resend in test/integration/account_email_confirmation_resend_test.rb

### Implementation for User Story 3

- [X] T039 [US3] Implement generic anti-enumeration resend response behavior in app/controllers/users/confirmations_controller.rb
- [X] T040 [US3] Implement per-account/email resend cooldown logic (5 minutes) in app/controllers/users/confirmations_controller.rb
- [X] T041 [US3] Implement latest-token-only acceptance safeguards aligned with Devise flow in app/controllers/users/confirmations_controller.rb
- [X] T042 [US3] Add audit logging hooks for send/resend/confirm events in app/controllers/users/confirmations_controller.rb

**Checkpoint**: US3 is fully functional and independently testable.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final documentation, consistency, and end-to-end validation.

- [X] T043 [P] Update feature documentation in English (toggle setup via ENV and credentials) in README.md
- [X] T044 [P] Add changelog entry for version 1.6.0 in README.md
- [X] T045 Align quickstart validation steps with final implementation paths in specs/001-account-email-verification/quickstart.md
- [X] T046 [P] Update data model notes with implemented field semantics and defaults in specs/001-account-email-verification/data-model.md
- [X] T047 Run focused auth/confirmation tests and record results in specs/001-account-email-verification/quickstart.md
- [X] T048 Run full test suite and record final validation summary in specs/001-account-email-verification/quickstart.md
- [ ] T049 [P] Run visual/interaction review for auth confirmation UX (sign-up, sign-in blocked, resend flows) and attach evidence in specs/001-account-email-verification/quickstart.md
- [ ] T050 [P] Capture baseline p95 sign-up latency before feature implementation and record method/results in specs/001-account-email-verification/quickstart.md
- [ ] T051 [P] Capture post-implementation p95 sign-up latency and compare against baseline in specs/001-account-email-verification/quickstart.md
- [X] T052 Document performance measurement rationale if any metric is not applicable in specs/001-account-email-verification/quickstart.md
- [X] T057 [P] Instrument and record confirmation email dispatch latency (account creation time to confirmation email delivery enqueue/sent) and validate SC-001 in specs/001-account-email-verification/quickstart.md
- [ ] T058 [P] Instrument and report confirmation conversion timing (email opened/received proxy to account confirmation) and validate SC-002 threshold in specs/001-account-email-verification/quickstart.md
- [X] T059 Define support-ticket baseline and 30-day post-release measurement method for "account created but cannot sign in" and validate SC-005 in specs/001-account-email-verification/quickstart.md

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1): starts immediately.
- Foundational (Phase 2): depends on Setup; blocks all user stories.
- User Stories (Phase 3+): all depend on Foundational completion.
- Polish (Phase 6): depends on completion of all targeted user stories.

### User Story Dependencies

- US1 (P1): starts after Foundational; no dependency on US2/US3.
- US2 (P1): starts after Foundational; functionally independent but shares auth controller paths with US1.
- US3 (P2): starts after Foundational; depends on confirmation infrastructure from US1 and controller wiring from Phase 2.

### Story Completion Order

- US1 → US2 → US3

### Within Each User Story

- Write tests first and verify they fail.
- Implement controller/model/config changes.
- Apply localization and contract alignment.
- Re-run targeted tests before closing the story.

## Parallel Opportunities

- Setup: T003 and T004 can run in parallel with T001/T002.
- Foundational: T011, T012, T016, and T017 can run in parallel after T009.
- US1 tests: T020, T021, T022, T023, and T055 can run in parallel.
- US2 tests: T028, T029, T030, and T053 can run in parallel.
- US3 tests: T035, T036, T037, and T038 can run in parallel.
- Polish docs/perf: T043, T044, T046, T049, T050, T057, and T058 can run in parallel.

## Parallel Example: User Story 1

- Run T020 + T021 + T022 + T023 + T055 together before implementation.
- After core code is in place, run T025 + T027 in parallel while T024 is stabilized.

## Parallel Example: User Story 2

- Run T028 + T029 + T030 + T053 together.
- Run T033 + T034 in parallel after T031 introduces message keys.

## Parallel Example: User Story 3

- Run T035 + T036 + T037 + T038 together.
- Run T040 + T042 in parallel once T039 establishes response contract.

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and Phase 2.
2. Complete Phase 3 (US1).
3. Validate US1 independently.
4. Demo/deploy MVP behavior.

### Incremental Delivery

1. Foundation complete.
2. Add US1 and validate.
3. Add US2 and validate.
4. Add US3 and validate.
5. Finish polish and full-suite verification.
6. Run SC-001/SC-002/SC-005 measurement tasks (T057, T058, T059) before final feature sign-off.

### Parallel Team Strategy

1. Team completes Setup + Foundational together.
2. Once Foundational is done:
   - Developer A: US1 flow.
   - Developer B: US2 sign-in gating.
   - Developer C: US3 resend/security behavior.
3. Merge by story checkpoints with independent test evidence.
