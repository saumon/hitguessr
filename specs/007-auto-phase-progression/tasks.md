# Tasks: Progression Automatique des Phases de Jeu

**Input**: Design documents from `/specs/007-auto-phase-progression/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, quickstart.md ✅

**Tests**: Tests inclus car requis par la constitution (Testing Standards - NON-NEGOTIABLE).

**Organization**: Tâches groupées par user story pour permettre l'implémentation et le test indépendants.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Peut s'exécuter en parallèle (fichiers différents, pas de dépendances)
- **[Story]**: User story concernée (US1, US2, US3)
- Chemins de fichiers exacts inclus

---

## Phase 1: Setup

**Purpose**: Pas de setup nécessaire - projet Rails existant avec structure en place.

> ✅ Aucune tâche requise - le projet est déjà configuré.

---

## Phase 2: Foundational (Méthodes de Base dans Game)

**Purpose**: Méthodes de détection partagées par US1 et US2 - DOIT être complet avant d'implémenter les user stories.

**⚠️ CRITICAL**: Les callbacks des user stories dépendent de ces méthodes.

- [X] T001 Ajouter la méthode `all_members_submitted?` dans app/models/game.rb
- [X] T002 Ajouter la méthode `expected_guesses_count` dans app/models/game.rb
- [X] T003 Ajouter la méthode `all_guesses_submitted?` dans app/models/game.rb
- [X] T004 [P] Ajouter les tests unitaires pour `all_members_submitted?` dans test/models/game_test.rb
- [X] T005 [P] Ajouter les tests unitaires pour `expected_guesses_count` dans test/models/game_test.rb
- [X] T006 [P] Ajouter les tests unitaires pour `all_guesses_submitted?` dans test/models/game_test.rb
- [X] T007a [P] Ajouter test edge case: `all_members_submitted?` avec membre ajouté pendant collecte dans test/models/game_test.rb
- [X] T007b [P] Ajouter test edge case: `all_members_submitted?` avec membre retiré pendant collecte dans test/models/game_test.rb
- [X] T007c [P] Ajouter test de non-régression: `start_guessing!` manuel fonctionne toujours (FR-006) dans test/models/game_test.rb
- [X] T007d [P] Ajouter test de non-régression: `finish!` manuel fonctionne toujours (FR-006) dans test/models/game_test.rb
- [X] T007 Exécuter `bin/rails test test/models/game_test.rb` et vérifier que les nouveaux tests passent

**Checkpoint**: Méthodes de détection en place et testées - les user stories peuvent commencer.

---

## Phase 3: User Story 1 - Avancement automatique vers la phase de devinettes (Priority: P1) 🎯 MVP

**Goal**: Lorsque tous les membres de l'équipe ont soumis leur proposition, la partie passe automatiquement en phase de devinettes.

**Independent Test**: Créer une équipe de 3 joueurs, soumettre 2 propositions, puis observer que la 3ème proposition déclenche le passage en phase de devinettes.

### Tests pour User Story 1

- [X] T008 [US1] Ajouter le test unitaire `try_auto_progress_to_guessing! transitions when all members submitted` dans test/models/game_test.rb
- [X] T009 [US1] Ajouter le test unitaire `try_auto_progress_to_guessing! does not transition if not all submitted` dans test/models/game_test.rb
- [X] T010 [US1] Ajouter le test unitaire `try_auto_progress_to_guessing! does not transition if less than 2 proposals` dans test/models/game_test.rb

### Implementation pour User Story 1

- [X] T011 [US1] Ajouter la méthode `try_auto_progress_to_guessing!` avec `with_lock` dans app/models/game.rb
- [X] T012 [US1] Ajouter le callback `after_create_commit :try_auto_progress_game` dans app/models/proposal.rb
- [X] T013 [US1] Ajouter la méthode privée `try_auto_progress_game` dans app/models/proposal.rb
- [X] T014 [US1] Exécuter les tests unitaires et vérifier qu'ils passent

### Test système pour User Story 1

- [X] T015 [US1] Créer le fichier test/system/auto_phase_progression_test.rb avec le test `game automatically progresses to guessing when last proposal submitted`
- [X] T016 [US1] Exécuter `bin/rails test test/system/auto_phase_progression_test.rb` et vérifier que le test passe

**Checkpoint**: User Story 1 complète - une partie passe automatiquement en phase de devinettes quand tous ont soumis.

---

## Phase 4: User Story 2 - Terminaison automatique de la partie (Priority: P1)

**Goal**: Lorsque toutes les devinettes attendues ont été soumises, la partie se termine automatiquement.

**Independent Test**: Créer une partie en phase de devinettes avec 3 propositions, soumettre 5 devinettes, puis observer que la 6ème déclenche la fin de partie.

### Tests pour User Story 2

- [X] T017 [US2] Ajouter le test unitaire `try_auto_finish! transitions when all guesses submitted` dans test/models/game_test.rb
- [X] T018 [US2] Ajouter le test unitaire `try_auto_finish! does not transition if guesses missing` dans test/models/game_test.rb
- [X] T019 [US2] Ajouter le test unitaire `try_auto_finish! does not transition if not in guessing phase` dans test/models/game_test.rb

### Implementation pour User Story 2

- [X] T020 [US2] Ajouter la méthode `try_auto_finish!` avec `with_lock` dans app/models/game.rb
- [X] T021 [US2] Ajouter le callback `after_create_commit :try_auto_finish_game` dans app/models/guess.rb
- [X] T022 [US2] Ajouter la méthode privée `try_auto_finish_game` dans app/models/guess.rb
- [X] T023 [US2] Exécuter les tests unitaires et vérifier qu'ils passent

### Test système pour User Story 2

- [X] T024 [US2] Ajouter le test système `game automatically finishes when last guess submitted` dans test/system/auto_phase_progression_test.rb
- [X] T025 [US2] Exécuter `bin/rails test test/system/auto_phase_progression_test.rb` et vérifier que tous les tests passent

**Checkpoint**: User Story 2 complète - une partie se termine automatiquement quand toutes les devinettes sont soumises.

---

## Phase 5: User Story 3 - Notification de la progression automatique (Priority: P2)

**Goal**: Les joueurs sont informés visuellement lorsque la partie progresse automatiquement.

**Independent Test**: Observer qu'un message flash ou indicateur apparaît après une progression automatique.

### Implementation pour User Story 3

- [X] T026 [US3] Modifier le redirect dans app/controllers/proposals_controller.rb#create pour afficher un flash notice spécifique si la partie a progressé automatiquement
- [X] T027 [US3] Modifier le redirect dans app/controllers/guesses_controller.rb#create pour afficher un flash notice spécifique si la partie s'est terminée automatiquement
- [X] T028 [P] [US3] Ajouter le test système `flash notice indicates automatic phase progression` dans test/system/auto_phase_progression_test.rb
- [X] T029 [P] [US3] Ajouter le test système `flash notice indicates automatic game finish` dans test/system/auto_phase_progression_test.rb
- [X] T030 [US3] Exécuter tous les tests système et vérifier qu'ils passent

**Checkpoint**: User Story 3 complète - les utilisateurs sont informés des progressions automatiques.

---

## Phase 6: Polish & Validation

**Purpose**: Validation finale et nettoyage

- [X] T031 [P] Exécuter `bin/rubocop app/models/game.rb app/models/proposal.rb app/models/guess.rb` et corriger les violations
- [X] T032 [P] Exécuter `bin/rails test` pour vérifier que tous les tests existants passent toujours
- [X] T033 Vérifier manuellement le scénario complet: créer équipe → créer partie → soumettre propositions → auto-progress → soumettre devinettes → auto-finish
- [X] T034 Mettre à jour la documentation si nécessaire

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: N/A - pas de tâches
- **Phase 2 (Foundational)**: Pas de dépendances - peut commencer immédiatement
- **Phase 3 (US1)**: Dépend de Phase 2 (T001-T003)
- **Phase 4 (US2)**: Dépend de Phase 2 (T001-T003) - peut s'exécuter en parallèle de Phase 3
- **Phase 5 (US3)**: Dépend de Phase 3 et Phase 4 (les méthodes de transition doivent exister)
- **Phase 6 (Polish)**: Dépend de toutes les phases précédentes

### User Story Dependencies

- **User Story 1 (P1)**: Dépend uniquement de Foundational (Phase 2)
- **User Story 2 (P1)**: Dépend uniquement de Foundational (Phase 2) - indépendante de US1
- **User Story 3 (P2)**: Dépend de US1 et US2 (doit savoir si une transition automatique a eu lieu)

### Parallel Opportunities per Phase

**Phase 2 (Foundational)**:

```text
T001, T002, T003 (séquentiels - même fichier)
│
├── T004, T005, T006 (parallèles - tests indépendants)
│
└── T007 (après T001-T006)
```

**Phase 3 + Phase 4 (US1 et US2 en parallèle)**:

```text
          Phase 2 complete
                │
    ┌───────────┴───────────┐
    │                       │
Phase 3 (US1)          Phase 4 (US2)
T008-T016              T017-T025
```

**Phase 5 (US3)**:

```text
T026, T027 (séquentiels - peuvent modifier controllers)
│
├── T028, T029 (parallèles - tests indépendants)
│
└── T030 (après tous)
```

---

## Implementation Strategy

### MVP Scope

**MVP = User Story 1 (Phase 3) seule** permet déjà de valider le comportement automatique sur la première transition. Recommandé pour une première itération.

### Full Feature

Implémenter dans l'ordre:

1. **Phase 2**: Foundational (obligatoire)
2. **Phase 3**: US1 - Auto-progress to guessing (MVP)
3. **Phase 4**: US2 - Auto-finish game
4. **Phase 5**: US3 - Notifications (optionnel mais améliore l'UX)
5. **Phase 6**: Polish

### Task Summary

| Phase | Tâches | Parallélisables |
| ----- | ------ | --------------- |
| Phase 1 (Setup) | 0 | - |
| Phase 2 (Foundational) | 7 | 3 |
| Phase 3 (US1) | 9 | 2 |
| Phase 4 (US2) | 9 | 2 |
| Phase 5 (US3) | 5 | 2 |
| Phase 6 (Polish) | 4 | 2 |
| **Total** | **34** | **11** |
