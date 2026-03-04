# Tasks: Repositionnement du bouton quitter l’équipe

**Input**: Design documents from `/specs/016-reposition-leave-team-button/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/leave-team-ui.openapi.yaml, quickstart.md

**Tests**: Tests requis pour tout comportement modifié (constitution projet + spec).

**Organization**: Tâches groupées par user story pour implémentation et validation indépendantes.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Préparer les fichiers de test et i18n qui seront utilisés par toutes les stories

- [X] T001 Créer le squelette de test système de la feature dans test/system/team_leave_button_positioning_test.rb
- [X] T002 [P] Créer le squelette de test système i18n dans test/system/team_leave_button_localization_test.rb
- [X] T003 [P] Préparer les clés de traduction de l’action leave dans config/locales/fr.yml
- [X] T004 [P] Préparer les clés de traduction de l’action leave dans config/locales/en.yml

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Mettre en place les fondations UI communes avant les stories

**⚠️ CRITICAL**: Aucun développement de story avant la fin de cette phase

- [X] T005 Créer app/helpers/teams_helper.rb (si absent) et ajouter un helper de libellé leave avec fallback explicite
- [X] T006 Ajouter dans app/helpers/teams_helper.rb un helper de rendu d’action leave pour membre connecté uniquement
- [X] T007 Adapter la vue équipe pour consommer les helpers partagés sans changer le flux métier dans app/views/teams/show.html.erb
- [X] T008 Ajouter un test helper/view pour les helpers leave dans test/helpers/teams_helper_test.rb

**Checkpoint**: Fondations prêtes, les user stories peuvent démarrer

---

## Phase 3: User Story 1 - Réduire les clics accidentels (Priority: P1) 🎯 MVP

**Goal**: Déplacer l’action de sortie vers la ligne du membre connecté, alignée à droite, et la retirer de l’ancien emplacement

**Independent Test**: Vérifier que l’action n’est plus dans l’en-tête et qu’elle apparaît uniquement sur la ligne du membre connecté

### Tests for User Story 1

- [X] T009 [P] [US1] Ajouter un test système de non-régression d’emplacement (ancien emplacement absent) dans test/system/team_leave_button_positioning_test.rb
- [X] T010 [P] [US1] Ajouter un test système de présence sur la ligne du membre connecté dans test/system/team_leave_button_positioning_test.rb
- [X] T011 [P] [US1] Ajouter un test contrôleur de non-régression du endpoint DELETE /teams/:team_id/leave dans test/controllers/memberships_controller_test.rb

### Implementation for User Story 1

- [X] T012 [US1] Retirer le bouton leave de l’ancien bloc d’actions d’en-tête dans app/views/teams/show.html.erb
- [X] T013 [US1] Ajouter le bouton leave sur la ligne du membre connecté dans la section membres dans app/views/teams/show.html.erb
- [X] T014 [US1] Appliquer l’alignement à droite desktop du bouton leave sur la ligne ciblée dans app/views/teams/show.html.erb
- [X] T015 [US1] Garantir la visibilité uniquement pour membre actif autorisé dans app/views/teams/show.html.erb

**Checkpoint**: US1 est complète et testable indépendamment (MVP)

---

## Phase 4: User Story 2 - Clarifier le libellé de l’action (Priority: P2)

**Goal**: Afficher un libellé localisé avec fallback `Quitter l'équipe` sans modifier le comportement métier

**Independent Test**: Vérifier le libellé selon locale active et fallback en absence de traduction

### Tests for User Story 2

- [X] T016 [P] [US2] Ajouter un test système du libellé localisé en FR dans test/system/team_leave_button_localization_test.rb
- [X] T017 [P] [US2] Ajouter un test système du fallback `Quitter l'équipe` si clé absente dans test/system/team_leave_button_localization_test.rb

### Implementation for User Story 2

- [X] T018 [US2] Ajouter/mettre à jour la clé i18n du bouton leave en français dans config/locales/fr.yml
- [X] T019 [P] [US2] Ajouter/mettre à jour la clé i18n du bouton leave en anglais dans config/locales/en.yml
- [X] T020 [US2] Remplacer le libellé hardcodé par le helper i18n avec fallback dans app/views/teams/show.html.erb
- [X] T021 [US2] Vérifier qu’aucune logique métier leave n’est modifiée dans app/controllers/memberships_controller.rb

**Checkpoint**: US1 + US2 fonctionnent indépendamment

---

## Phase 5: User Story 3 - Conserver la lisibilité de la liste des membres (Priority: P3)

**Goal**: Assurer une intégration visuelle lisible, y compris en mobile (2e ligne sous infos membre, alignée à droite)

**Independent Test**: Vérifier en desktop/mobile qu’aucun chevauchement n’apparaît et que l’action reste identifiable

### Tests for User Story 3

- [X] T022 [P] [US3] Ajouter un test système mobile pour vérifier le layout sur seconde ligne dans test/system/team_leave_button_positioning_test.rb
- [X] T023 [P] [US3] Ajouter un test système de lisibilité avec liste membres longue dans test/system/team_leave_button_positioning_test.rb

### Implementation for User Story 3

- [X] T024 [US3] Ajuster les classes responsive pour passer le bouton sous les infos membre sur petit écran dans app/views/teams/show.html.erb
- [X] T025 [US3] Garantir l’alignement à droite sur mobile et desktop sans chevauchement dans app/views/teams/show.html.erb
- [X] T026 [US3] Ajuster les styles utilitaires de lisibilité de la ligne membre dans app/assets/stylesheets/application.css

**Checkpoint**: Toutes les user stories sont fonctionnelles et indépendamment testables

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Finaliser documentation, contrats et validation globale

- [X] T027 Mettre à jour le changelog dans README.md pour la version 1.3.3 avec la feature de repositionnement
- [X] T028 [P] Aligner le quickstart de validation final sur les implémentations livrées dans specs/016-reposition-leave-team-button/quickstart.md
- [X] T029 [P] Vérifier la cohérence finale du contrat UI/API avec l’implémentation dans specs/016-reposition-leave-team-button/contracts/leave-team-ui.openapi.yaml
- [X] T030 Exécuter les tests ciblés de la feature dans test/controllers/memberships_controller_test.rb
- [X] T031 Exécuter les tests système de la feature dans test/system/team_leave_button_positioning_test.rb
- [X] T032 Exécuter les tests système i18n de la feature dans test/system/team_leave_button_localization_test.rb
- [X] T033 Exécuter le lint Ruby/Rails du projet (ou sous-ensemble impacté) et corriger les écarts bloquants
- [X] T034 Exécuter le formatage applicable du projet et vérifier l’absence de diff inattendu
- [ ] T035 Réaliser une revue UX/interaction (desktop + mobile) sur 10 testeurs minimum avec scénario standardisé (ouvrir équipe → ouvrir section membres → repérer l’action de sortie) et consigner la validation SC-004
- [ ] T036 Mesurer la performance du flux leave (20 exécutions) et consigner la conformité SC-008 (p95 ≤ 2s)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: démarre immédiatement
- **Phase 2 (Foundational)**: dépend de Phase 1 et bloque toutes les stories
- **Phase 3-5 (User Stories)**: démarrent après Phase 2, en priorité P1 → P2 → P3
- **Phase 6 (Polish)**: dépend de la complétion des stories retenues

### User Story Dependencies

- **US1 (P1)**: dépend uniquement de la Phase 2
- **US2 (P2)**: dépend de la Phase 2; peut réutiliser la vue modifiée en US1
- **US3 (P3)**: dépend de la Phase 2; s’appuie sur le rendu US1

### Within Each User Story

- Tests d’abord, puis implémentation
- Rendu UI avant ajustements responsive avancés
- Story validée indépendamment avant passage à la suivante

## Parallel Opportunities

- **Setup**: T002, T003, T004 en parallèle
- **Foundational**: T005/T006 peuvent avancer en parallèle puis converger sur T007
- **US1**: T009/T010/T011 en parallèle
- **US2**: T016/T017/T019 en parallèle
- **US3**: T022/T023 en parallèle
- **Polish**: T028/T029 en parallèle

## Parallel Example: User Story 1

```bash
# Tests US1 en parallèle
Task: T009 test ancien emplacement absent dans test/system/team_leave_button_positioning_test.rb
Task: T010 test présence sur ligne membre connecté dans test/system/team_leave_button_positioning_test.rb
Task: T011 test contrôleur leave non-régression dans test/controllers/memberships_controller_test.rb
```

## Parallel Example: User Story 2

```bash
# Préparer i18n + tests US2 en parallèle
Task: T016 test libellé FR dans test/system/team_leave_button_localization_test.rb
Task: T017 test fallback dans test/system/team_leave_button_localization_test.rb
Task: T019 mise à jour clé EN dans config/locales/en.yml
```

## Parallel Example: User Story 3

```bash
# Tests responsive US3 en parallèle
Task: T022 test layout mobile seconde ligne dans test/system/team_leave_button_positioning_test.rb
Task: T023 test lisibilité liste longue dans test/system/team_leave_button_positioning_test.rb
```

## Implementation Strategy

### MVP First (US1 Only)

1. Terminer Phase 1
2. Terminer Phase 2 (bloquant)
3. Livrer US1 (Phase 3)
4. Valider indépendamment US1

### Incremental Delivery

1. Setup + Foundational
2. US1 (positionnement)
3. US2 (libellé localisé + fallback)
4. US3 (lisibilité responsive)
5. Polish (README changelog 1.3.3 + validation finale)
