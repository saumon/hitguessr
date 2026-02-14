# Tasks: HitGuessr - Jeu de devinettes musicales en équipe

**Input**: Design documents from `/specs/001-hitguessr-gameplay/`  
**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, contracts/ ✓, quickstart.md ✓

**Tests**: Inclus par user story (constitution Principle II). Minitest pour modèles, System tests Capybara pour flux utilisateur. Approche: tests écrits après implémentation de chaque composant (test-after), exécutés avant checkpoint.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

Rails 8.1.2 standard structure:

- **Models**: `app/models/`
- **Controllers**: `app/controllers/`
- **Views**: `app/views/`
- **Config**: `config/`
- **Migrations**: `db/migrate/`
- **Tests**: `test/`

---

## Phase 1: Setup (Project Initialization)

**Purpose**: Création du projet Rails avec dépendances de base

- [X] T001 Create Rails 8.1.2 project with TailwindCSS: `rails new hitguessr --css tailwind --database sqlite3`
- [X] T002 Add Devise gem to Gemfile and run `bundle install`
- [X] T003 [P] Configure RuboCop with `rubocop-rails-omakase` in `.rubocop.yml`
- [X] T004 [P] Add test gems (capybara, selenium-webdriver) to Gemfile test group
- [X] T005 Run `rails generate devise:install` and configure Devise initializer in `config/initializers/devise.rb`
- [X] T006 Run `rails generate devise User` to create User model with Devise
- [X] T007 Create migration to add `name` field to users: `db/migrate/xxx_add_name_to_users.rb`
- [X] T008 Configure Devise for Turbo/Hotwire in `config/initializers/devise.rb` (error_status, redirect_status)

---

## Phase 2: Foundational (Database Schema & Core Models)

**Purpose**: Schéma de base de données et modèles de base requis par TOUTES les user stories

**⚠️ CRITICAL**: Aucune user story ne peut démarrer avant la fin de cette phase

- [X] T009 Create Team model migration in `db/migrate/xxx_create_teams.rb` (name, organizer_id FK)
- [X] T010 [P] Create Membership model migration in `db/migrate/xxx_create_memberships.rb` (user_id, team_id, unique index)
- [X] T011 [P] Create Game model migration in `db/migrate/xxx_create_games.rb` (team_id, status enum, started_at, finished_at)
- [X] T012 [P] Create Proposal model migration in `db/migrate/xxx_create_proposals.rb` (game_id, player_id, url, unique indexes)
- [X] T013 [P] Create Guess model migration in `db/migrate/xxx_create_guesses.rb` (player_id, proposal_id, guessed_author_id, unique index)
- [X] T014 Run `rails db:migrate` to apply all migrations
- [X] T015 Implement User model with Devise modules and name validation in `app/models/user.rb`
- [X] T016 [P] Implement Team model with associations and validations in `app/models/team.rb`
- [X] T017 [P] Implement Membership model with associations and uniqueness validation in `app/models/membership.rb`
- [X] T018 [P] Implement Game model with enum, state transitions (`start_guessing!`, `finish!`) in `app/models/game.rb`
- [X] T019 [P] Implement Proposal model with URL validation and normalization in `app/models/proposal.rb`
- [X] T020 [P] Implement Guess model with associations and validations in `app/models/guess.rb`
- [X] T021 Configure routes structure in `config/routes.rb` (Devise, Teams, Games nested resources)
- [X] T022 Create ApplicationController with authentication helper in `app/controllers/application_controller.rb`
- [X] T023 Create application layout with header/footer in `app/views/layouts/application.html.erb`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Créer une équipe et collecter les propositions (Priority: P1) 🎯 MVP

**Goal**: L'organisateur crée une équipe, sélectionne ses membres et lance une partie pour collecter les propositions musicales

**Independent Test**: Lancer une partie, faire soumettre une proposition par chaque membre, vérifier que les propositions sont enregistrées et invisibles aux autres joueurs

### Implementation for User Story 1

#### Teams Management

- [X] T024 [US1] Implement TeamsController with index, show, new, create, edit, update, destroy in `app/controllers/teams_controller.rb`
- [X] T025 [P] [US1] Create teams/index view (liste des équipes) in `app/views/teams/index.html.erb`
- [X] T026 [P] [US1] Create teams/show view (détail équipe + membres) in `app/views/teams/show.html.erb`
- [X] T027 [P] [US1] Create teams/new view (formulaire création) in `app/views/teams/new.html.erb`
- [X] T028 [P] [US1] Create teams/_form partial in `app/views/teams/_form.html.erb`
- [X] T029 [P] [US1] Create teams/edit view in `app/views/teams/edit.html.erb`

#### Memberships Management

- [X] T030 [US1] Implement MembershipsController with create, destroy (organizer only) in `app/controllers/memberships_controller.rb`
- [X] T031 [US1] Extend teams/show with member selection UI (user search by email) in `app/views/teams/show.html.erb`
- [X] T032 [US1] Auto-create membership for organizer when Team is created (callback in `app/models/team.rb`)

#### Games - Creating & Collecting Phase

- [X] T033 [US1] Implement GamesController with index, new, create, show in `app/controllers/games_controller.rb`
- [X] T034 [P] [US1] Create games/index view (liste parties de l'équipe) in `app/views/games/index.html.erb`
- [X] T035 [P] [US1] Create games/new view (formulaire nouvelle partie) in `app/views/games/new.html.erb`
- [X] T036 [US1] Create games/show view with phase partials (`_collecting`, `_guessing`, `_finished`) in `app/views/games/show.html.erb`
- [X] T037 [US1] Add authorization check: only organizer can create games in `app/controllers/games_controller.rb`

#### Proposals - Submitting

- [X] T038 [US1] Implement ProposalsController with new, create, show in `app/controllers/proposals_controller.rb`
- [X] T039 [P] [US1] Create proposals/new view (formulaire proposition) in `app/views/proposals/new.html.erb`
- [X] T040 [P] [US1] Create proposals/show view (voir ma proposition only) in `app/views/proposals/show.html.erb`
- [X] T041 [US1] Add authorization: only team member during collecting phase can submit in `app/controllers/proposals_controller.rb`
- [X] T042 [US1] Ensure proposals are invisible to other players (no public index) in `app/controllers/proposals_controller.rb`

#### Game Phase Transition (Collecting → Guessing)

- [X] T043 [US1] Implement start_guessing action in GamesController (organizer only) in `app/controllers/games_controller.rb`
- [X] T044 [US1] Add "Passer aux devinettes" button in games/show (organizer only, visible in collecting phase) in `app/views/games/show.html.erb`
- [X] T045 [US1] Handle exclusion of players without proposals when transitioning to guessing phase in `app/models/game.rb`

#### Tests for User Story 1

- [X] T074 [US1] Unit test for Team model validations in `test/models/team_test.rb`
- [X] T075 [P] [US1] Unit test for Proposal URL validation and normalization in `test/models/proposal_test.rb`
- [X] T076 [US1] System test: create team, add members, launch game in `test/system/teams_test.rb`
- [X] T077 [US1] System test: submit proposal, verify invisibility in `test/system/proposals_test.rb`

#### Edge Case Tests (FR-012)

- [X] T078 [US1] System test: player without proposal excluded from guessing pool in `test/system/edge_cases_test.rb`
- [X] T079 [US2] System test: player without guesses gets score 0 in `test/system/edge_cases_test.rb`
- [X] T080 [US1] Unit test: duplicate URL rejection with normalization in `test/models/proposal_test.rb`

**Checkpoint**: User Story 1 complete - Teams can be created, members added, games launched, and proposals collected

---

## Phase 4: User Story 2 - Deviner qui a proposé quelle musique (Priority: P2)

**Goal**: Les joueurs participent à la phase de devinettes en associant chaque proposition à un membre

**Independent Test**: Ouvrir la phase de devinettes, associer chaque proposition à un membre, valider une soumission complète de devinettes

### Implementation for User Story 2

- [X] T046 [US2] Update games/show view for guessing phase (propositions anonymisées, progression) in `app/views/games/show.html.erb`
- [X] T047 [US2] Implement GuessesController with new, create in `app/controllers/guesses_controller.rb`
- [X] T048 [US2] Create guesses/new view (formulaire devinettes - toutes propositions) in `app/views/guesses/new.html.erb`
- [X] T049 [US2] Implement batch submission of all guesses (transaction) in `app/controllers/guesses_controller.rb`
- [X] T050 [US2] Add validation: all proposals must be guessed before submission in `app/controllers/guesses_controller.rb`
- [X] T051 [US2] Add authorization: only team member during guessing phase can submit in `app/controllers/guesses_controller.rb`
- [X] T052 [US2] Lock guesses after submission (no update/delete routes) - enforced by routes in `config/routes.rb`
- [X] T053 [US2] Add "Faire mes devinettes" button in games/show (visible in guessing phase if not submitted) in `app/views/games/show.html.erb`

#### Game Phase Transition (Guessing → Finished)

- [X] T054 [US2] Implement finish action in GamesController (organizer only) in `app/controllers/games_controller.rb`
- [X] T055 [US2] Add "Terminer la partie" button in games/show (organizer only, visible in guessing phase) in `app/views/games/show.html.erb`
- [X] T056 [US2] Handle players without guesses when finishing (score = 0) in `app/models/game.rb`

#### Tests for User Story 2

- [X] T081 [US2] Unit test for Guess model validations in `test/models/guess_test.rb`
- [X] T082 [US2] Unit test for Game state transitions in `test/models/game_test.rb`
- [X] T083 [US2] System test: submit all guesses, verify lock in `test/system/guesses_test.rb`

**Checkpoint**: User Story 2 complete - Players can make guesses and games can be finished

---

## Phase 5: User Story 3 - Afficher résultats et classement (Priority: P3)

**Goal**: Les joueurs consultent les résultats détaillés et le classement final

**Independent Test**: Clôturer la phase de devinettes, vérifier l'affichage des scores et du classement avec gestion ex aequo

### Implementation for User Story 3

- [X] T057 [US3] Implement calculate_scores method in Game model in `app/models/game.rb`
- [X] T058 [US3] Implement ranking method with ex aequo handling in Game model in `app/models/game.rb`
- [X] T059 [US3] Implement ResultsController with show action in `app/controllers/results_controller.rb`
- [X] T060 [US3] Create results/show view (classement + détail propositions) in `app/views/results/show.html.erb`
- [X] T061 [US3] Add authorization: only team members can view results after game finished in `app/controllers/results_controller.rb`
- [X] T062 [US3] Update games/show view for finished phase (link to results) in `app/views/games/show.html.erb`
- [X] T063 [US3] Display correct answer and player's guess for each proposal in results in `app/views/results/show.html.erb`

#### Tests for User Story 3

- [X] T084 [US3] Unit test for calculate_scores and ranking methods in `test/models/game_test.rb`
- [X] T085 [US3] System test: full game cycle with results display in `test/system/results_test.rb`

**Checkpoint**: User Story 3 complete - Full game cycle works end-to-end

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Améliorations transversales et finalisation

- [X] T064 [P] Style all views with TailwindCSS v4.1 for visual consistency in `app/views/**/*.html.erb`
- [X] T065 [P] Add flash messages display in application layout in `app/views/layouts/application.html.erb`
- [X] T066 [P] Add French translations for Devise messages in `config/locales/devise.fr.yml`
- [X] T067 [P] Add French translations for custom messages in `config/locales/fr.yml`
- [X] T068 [P] Set French as default locale in `config/application.rb`
- [X] T069 Implement proper error handling for invalid transitions in controllers
- [ ] T070 Add accessibility improvements (labels, contraste, navigation clavier)
- [X] T071 [P] Run RuboCop and fix linting issues
- [X] T072 [P] Create seed data for development testing in `db/seeds.rb`
- [X] T073 Run quickstart.md validation - verify full game cycle works
- [ ] T086 [P] Performance test: results page loads in <2s for 10-player game in `test/performance/results_test.rb`
- [ ] T087 UX consistency review: verify all main screens against contracts/views.md wireframes

---

## Dependencies & Execution Order

### Phase Dependencies

```text
Phase 1: Setup
    ↓
Phase 2: Foundational (BLOCKS all user stories)
    ↓
┌───────────────────────────────────────────┐
│  Phase 3: US1 (P1) - Équipes & Collecte   │ ← MVP
│              ↓                            │
│  Phase 4: US2 (P2) - Devinettes           │
│              ↓                            │
│  Phase 5: US3 (P3) - Résultats            │
└───────────────────────────────────────────┘
    ↓
Phase 6: Polish
```

### User Story Dependencies

- **User Story 1 (P1)**: Depends on Foundational only - **Can be delivered as MVP**
- **User Story 2 (P2)**: Depends on US1 (needs proposals to guess) - Extends MVP
- **User Story 3 (P3)**: Depends on US2 (needs guesses to score) - Completes game cycle

### Within Each User Story

- Models and migrations before controllers
- Controllers before views
- Authorization after basic CRUD
- Phase transitions after core functionality

### Parallel Opportunities

**Phase 1 (Setup)**:

- T003, T004 can run in parallel

**Phase 2 (Foundational)**:

- T010, T011, T012, T013 (migrations) can run in parallel
- T016, T017, T018, T019, T020 (models) can run in parallel

**Phase 3 (US1)**:

- T025, T026, T027, T028, T029 (team views) can run in parallel
- T034, T035 (game views) can run in parallel
- T039, T040 (proposal views) can run in parallel

**Phase 6 (Polish)**:

- T064, T065, T066, T067, T068, T071, T072 can run in parallel

---

## Implementation Strategy

### MVP Scope (Recommended)

**User Story 1 only** = Équipes créées, membres gérés, parties lancées, propositions collectées

Cela permet de valider:

- Infrastructure Rails fonctionne
- Devise authentification OK
- Modèles et relations corrects
- Flow de collecte opérationnel

### Incremental Delivery

1. **MVP (US1)**: Collecte fonctionnelle → Testable en isolation
2. **+US2**: Phase devinettes → Jeu presque complet
3. **+US3**: Résultats et classement → Cycle complet
4. **+Polish**: Production-ready

---

## Validation Checklist

Before marking a user story complete:

- [ ] All acceptance scenarios from spec.md pass
- [ ] Authorization rules enforced per contracts/routes.md
- [ ] Views match wireframes in contracts/views.md
- [ ] Edge cases handled (no proposal, no guesses, duplicates)
- [ ] Flash messages provide user feedback
- [ ] No RuboCop errors
