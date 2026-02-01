# Tasks: Responsive Design

**Input**: Design documents from `/specs/005-responsive-design/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, quickstart.md ✅

**Tests**: Tests système multi-viewport inclus pour valider les comportements responsive.

**Organization**: Tasks groupées par user story pour permettre l'implémentation et les tests indépendants de chaque story.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Peut s'exécuter en parallèle (fichiers différents, pas de dépendances)
- **[Story]**: User story associée (US1, US2, US3, US4)
- Chemins de fichiers exacts dans les descriptions

---

## Phase 1: Setup (Infrastructure partagée)

**Purpose**: Configuration de base et utilitaires responsive partagés

- [X] T001 Ajouter support prefers-reduced-motion et overflow-x-hidden dans app/assets/tailwind/application.css
- [X] T002 [P] Créer helpers de test viewport dans test/application_system_test_case.rb

---

## Phase 2: Foundational (Prérequis bloquants)

**Purpose**: Layout principal responsive qui affecte TOUTES les pages

**⚠️ CRITICAL**: La navigation responsive doit être terminée avant les user stories

- [X] T003 Optimiser navigation header mobile dans app/views/layouts/application.html.erb (masquer éléments secondaires, réduire espacements)
- [X] T004 Vérifier et ajuster zones tactiles (min 44x44px) dans app/views/layouts/application.html.erb
- [X] T005 [P] Vérifier responsive du footer dans app/views/layouts/application.html.erb

**Checkpoint**: Layout principal responsive - les pages individuelles peuvent maintenant être traitées

---

## Phase 3: User Story 1 - Navigation mobile fluide (Priority: P1) 🎯 MVP

**Goal**: Navigation accessible et utilisable sur smartphone sans défilement horizontal

**Independent Test**: Accéder à toutes les pages principales depuis un viewport mobile (375x667) et vérifier l'accessibilité

### Tests pour User Story 1

- [X] T006 [US1] Créer test système navigation mobile dans test/system/responsive_navigation_test.rb

### Implementation pour User Story 1

- [X] T007 [P] [US1] Rendre responsive la page d'accueil dans app/views/home/index.html.erb
- [X] T008 [P] [US1] Rendre responsive la liste des équipes dans app/views/teams/index.html.erb
- [X] T009 [P] [US1] Rendre responsive la page équipe dans app/views/teams/show.html.erb
- [X] T010 [US1] Vérifier absence de défilement horizontal sur toutes les pages principales

**Checkpoint**: Navigation mobile fonctionnelle et testée - MVP utilisable sur smartphone

---

## Phase 4: User Story 2 - Expérience de jeu sur tablette (Priority: P2)

**Goal**: Interface de jeu exploitant l'espace tablette avec layout multi-colonnes si pertinent

**Independent Test**: Jouer une partie complète sur viewport tablette (768x1024)

### Tests pour User Story 2

- [X] T011 [US2] Créer test système gameplay tablette dans test/system/responsive_game_test.rb

### Implementation pour User Story 2

- [X] T012 [P] [US2] Rendre responsive la page de jeu dans app/views/games/show.html.erb
- [X] T013 [P] [US2] Rendre responsive le partial collecting dans app/views/games/_collecting.html.erb
- [X] T014 [P] [US2] Rendre responsive le partial guessing dans app/views/games/_guessing.html.erb
- [X] T015 [P] [US2] Rendre responsive le partial finished dans app/views/games/_finished.html.erb
- [X] T016 [US2] Transformer tableaux de résultats en cartes empilées sur mobile dans app/views/results/show.html.erb
- [X] T017 [P] [US2] Rendre responsive les formulaires de propositions dans app/views/proposals/

**Checkpoint**: Parcours de jeu complet fonctionnel sur tablette et mobile

---

## Phase 5: User Story 3 - Affichage optimal sur écran PC (Priority: P3)

**Goal**: Interface exploitant l'espace desktop sans étirement excessif, avec indicateurs de survol

**Independent Test**: Vérifier que le contenu reste centré et lisible sur viewport large (1440x900)

### Tests pour User Story 3

- [X] T018 [US3] Créer test système affichage desktop dans test/system/responsive_desktop_test.rb

### Implementation pour User Story 3

- [X] T019 [US3] Vérifier largeurs maximales et centrage sur toutes les pages (max-w-4xl, mx-auto)
- [X] T020 [P] [US3] Ajouter/vérifier effets de survol (hover:) sur éléments interactifs
- [X] T021 [US3] Tester comportement sur écrans très larges (> 1440px)

**Checkpoint**: Expérience desktop optimale sans étirement

---

## Phase 6: User Story 4 - Transition fluide entre appareils (Priority: P4)

**Goal**: Interface s'adaptant instantanément lors de changement d'orientation ou redimensionnement

**Independent Test**: Redimensionner la fenêtre ou changer l'orientation pendant une session

### Tests pour User Story 4

- [X] T022 [US4] Créer test système transitions responsive dans test/system/responsive_transitions_test.rb

### Implementation pour User Story 4

- [X] T023 [US4] Vérifier absence de CLS (Cumulative Layout Shift) lors des transitions
- [X] T024 [US4] Vérifier préservation du contexte lors du changement d'orientation (pas de rechargement)

**Checkpoint**: Transitions fluides sans perte de contexte

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Améliorations finales et validation globale

- [X] T025 [P] Vérifier responsive des vues Devise (login, register) dans app/views/devise/
- [X] T026 Exécuter quickstart.md validation (vérification manuelle multi-viewport)
- [X] T027 [P] Documenter les patterns responsive utilisés dans specs/005-responsive-design/

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Pas de dépendances - peut commencer immédiatement
- **Foundational (Phase 2)**: Dépend de Setup - BLOQUE toutes les user stories
- **User Stories (Phase 3-6)**: Toutes dépendent de Foundational
  - Peuvent progresser en parallèle si plusieurs développeurs
  - Ou séquentiellement par priorité (P1 → P2 → P3 → P4)
- **Polish (Phase 7)**: Dépend de toutes les user stories souhaitées

### User Story Dependencies

- **User Story 1 (P1)**: Peut démarrer après Foundational - Pas de dépendances sur autres stories
- **User Story 2 (P2)**: Peut démarrer après Foundational - Peut être fait en parallèle de US1
- **User Story 3 (P3)**: Peut démarrer après Foundational - Peut être fait en parallèle
- **User Story 4 (P4)**: Peut démarrer après US1-US3 (dépend d'avoir du contenu responsive à tester)

### Within Each User Story

- Tests d'abord (si inclus)
- Vues principales avant vues secondaires
- Vérification globale en fin de story

### Parallel Opportunities

- T001, T002 peuvent s'exécuter en parallèle (Phase 1)
- T003, T004, T005 : T004 et T005 peuvent être en parallèle après T003
- T007, T008, T009 peuvent s'exécuter en parallèle (US1 vues)
- T012, T013, T014, T015, T017 peuvent s'exécuter en parallèle (US2 vues)
- T019, T020 peuvent s'exécuter en parallèle (US3)

---

## Parallel Example: Phase 1 + US2

```bash
# Phase 1 - en parallèle :
T001: "Ajouter support prefers-reduced-motion + overflow-x-hidden"
T002: "Créer helpers de test viewport"

# US2 - vues en parallèle :
T012: "Rendre responsive games/show.html.erb"
T013: "Rendre responsive games/_collecting.html.erb"
T014: "Rendre responsive games/_guessing.html.erb"
T015: "Rendre responsive games/_finished.html.erb"
T017: "Rendre responsive proposals/"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Compléter Phase 1: Setup
2. Compléter Phase 2: Foundational (navigation responsive)
3. Compléter Phase 3: User Story 1 (pages principales)
4. **STOP et VALIDER**: Tester navigation mobile indépendamment
5. Déployer/démontrer si prêt

### Incremental Delivery

1. Setup + Foundational → Layout responsive prêt
2. User Story 1 → Navigation mobile OK → Démo (MVP!)
3. User Story 2 → Gameplay tablette OK → Démo
4. User Story 3 → Desktop optimal → Démo
5. User Story 4 → Transitions fluides → Démo final
6. Chaque story ajoute de la valeur sans casser les précédentes

---

## Notes

- [P] = fichiers différents, pas de dépendances
- [USx] = associe la tâche à la user story pour traçabilité
- Chaque user story doit être indépendamment complétable et testable
- Commit après chaque tâche ou groupe logique
- Stopper à chaque checkpoint pour valider la story indépendamment
- Éviter : tâches vagues, conflits de fichiers, dépendances cross-story qui cassent l'indépendance
