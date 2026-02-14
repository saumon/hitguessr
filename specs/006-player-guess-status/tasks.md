# Tasks: Tableau de statut des joueurs en phase de devinettes

**Input**: Design documents from `/specs/006-player-guess-status/`
**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, quickstart.md ✓

**Tests**: System test inclus pour valider le comportement.

**Organization**: Tasks grouped by user story for independent implementation.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: No setup required - feature modifies existing files only.

*N/A - Cette feature ne nécessite pas de setup initial.*

---

## Phase 2: Foundational

**Purpose**: No foundational work required - all infrastructure exists.

*N/A - Le controller et les vues existent déjà.*

---

## Phase 3: User Story 1 - Consulter le statut des joueurs (Priority: P1) 🎯 MVP

**Goal**: Afficher un tableau de statut des joueurs en phase de devinettes avec leur état de réponse.

**Independent Test**: Accéder à une partie en phase de devinettes et vérifier que le tableau liste tous les joueurs du pool avec leur statut correct (En attente / Devinette soumise).

### Implementation for User Story 1

- [X] T001 [US1] Add players_with_guesses calculation in app/controllers/games_controller.rb
- [X] T002 [US1] Pass players_with_guesses variable to _guessing partial in app/views/games/show.html.erb
- [X] T003 [US1] Add player status table section in app/views/games/_guessing.html.erb

### Tests for User Story 1

- [X] T004 [US1] Add system test for player status display in test/system/guesses_test.rb

**Checkpoint**: Le tableau de statut est visible en phase de devinettes avec les statuts corrects.

---

## Phase 4: User Story 2 - Cohérence visuelle (Priority: P2)

**Goal**: Assurer la cohérence visuelle avec le tableau de la phase de collecte.

**Independent Test**: Comparer visuellement les deux tableaux (collecte vs devinettes) et vérifier l'adaptation responsive.

### Implementation for User Story 2

*Déjà couvert par T003* - Le markup HTML/CSS réutilise la structure du tableau existant dans `_collecting.html.erb`.

**Checkpoint**: Les tableaux des deux phases sont visuellement identiques.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Validation finale et vérification de qualité.

- [X] T005 Run full test suite and verify no regressions

---

## Dependencies

```text
T001 → T002 → T003 → T004
                 ↘
                   T005
```

- T001 doit être complété avant T002 (la variable doit exister avant d'être passée)
- T002 doit être complété avant T003 (le partial doit recevoir la variable)
- T003 doit être complété avant T004 (le test valide le comportement implémenté)
- T005 peut être exécuté après T004

## Parallel Execution Opportunities

Cette feature est séquentielle par nature (chaque tâche dépend de la précédente). Pas d'opportunités de parallélisation significatives.

## Implementation Strategy

**MVP Scope**: User Story 1 (T001-T004) - Tableau de statut fonctionnel
**Full Scope**: Inclut US2 (couvert par T003) et validation finale (T005)

**Estimated Effort**: ~1-2 heures pour l'implémentation complète.

---

## Summary

| Metric | Value |
| ------ | ----- |
| Total Tasks | 5 |
| User Story 1 Tasks | 4 (T001-T004) |
| User Story 2 Tasks | 0 (couvert par T003) |
| Polish Tasks | 1 (T005) |
| Parallelizable Tasks | 0 |
| MVP Scope | T001-T004 |
