# Tasks: Classement général de l'équipe

**Input**: Design documents from `/specs/004-team-leaderboard/`  
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, quickstart.md ✅

**Tests**: Tests REQUIS pour tout nouveau comportement (unit tests et system tests).

**Organization**: Tâches groupées par user story pour permettre l'implémentation et le test indépendant de chaque story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Peut s'exécuter en parallèle (fichiers différents, pas de dépendances)
- **[Story]**: User story associée (US1, US2, US3)
- Chemins de fichiers exacts dans les descriptions

---

## Phase 1: Setup

**Purpose**: Pas de setup requis - infrastructure existante

> Cette feature ne nécessite pas de nouvelle infrastructure. Le projet Rails est déjà configuré avec les dépendances nécessaires.

**Checkpoint**: Pas de setup requis - passage direct à Phase 2

---

## Phase 2: Foundational (Prérequis bloquants)

**Purpose**: Méthode modèle de base qui DOIT être complète avant les user stories d'affichage

**⚠️ CRITICAL**: Les phases d'affichage (US1, US2, US3) dépendent de cette méthode

- [X] T001 Créer la méthode `Team#leaderboard` qui agrège les scores dans app/models/team.rb
- [X] T002 [P] Créer les tests unitaires pour `Team#leaderboard` dans test/models/team_test.rb (inclure: scores cumulés, tri décroissant, rangs ex aequo, partie avec 0 points pour tous)

**Checkpoint**: Méthode `leaderboard` fonctionnelle - tests passent, prêt pour l'affichage

---

## Phase 3: User Story 1 - Affichage du classement général (Priority: P1) 🎯 MVP

**Goal**: Afficher le classement général sur la page de l'équipe avec les scores cumulés triés par ordre décroissant

**Independent Test**: Se connecter comme membre d'une équipe ayant des parties terminées → consulter la page de l'équipe → voir le classement général avec les scores cumulés

### Tests pour User Story 1

- [X] T003 [P] [US1] Créer le fichier de test système test/system/team_leaderboard_test.rb avec test d'affichage du classement

### Implémentation pour User Story 1

- [X] T004 [US1] Ajouter `@leaderboard = @team.leaderboard` dans l'action `show` de app/controllers/teams_controller.rb
- [X] T005 [US1] Ajouter la section "Classement général" dans app/views/teams/show.html.erb
- [X] T006 [US1] Ajouter les traductions pour "Classement général" dans config/locales/fr.yml et config/locales/en.yml

**Checkpoint**: Le classement général est visible avec les scores triés par ordre décroissant

---

## Phase 4: User Story 2 - Affichage des médailles (Priority: P1)

**Goal**: Afficher les médailles 🥇🥈🥉 pour les 3 premiers du classement

**Independent Test**: Consulter le classement général d'une équipe avec au moins 3 joueurs → vérifier les médailles

### Tests pour User Story 2

- [X] T007 [P] [US2] Ajouter test système pour l'affichage des médailles dans test/system/team_leaderboard_test.rb

### Implémentation pour User Story 2

- [X] T008 [US2] Ajouter l'affichage des médailles (🥇🥈🥉) dans la section classement de app/views/teams/show.html.erb
- [X] T009 [US2] Ajouter test unitaire pour les ex aequo avec même médaille dans test/models/team_test.rb

**Checkpoint**: Les médailles sont affichées correctement, y compris pour les ex aequo

---

## Phase 5: User Story 3 - Gestion des équipes sans parties (Priority: P2)

**Goal**: Afficher un message approprié quand aucune partie terminée n'existe

**Independent Test**: Créer une équipe sans parties terminées → voir un message à la place du classement

### Tests pour User Story 3

- [X] T010 [P] [US3] Ajouter test système pour équipe sans parties dans test/system/team_leaderboard_test.rb

### Implémentation pour User Story 3

- [X] T011 [US3] Ajouter condition et message "Aucun classement disponible" dans app/views/teams/show.html.erb
- [X] T012 [US3] Ajouter les traductions pour le message vide dans config/locales/fr.yml et config/locales/en.yml

**Checkpoint**: Message approprié affiché pour équipes sans parties terminées

---

## Phase 6: Polish & Validation

**Purpose**: Validation finale et tests d'intégration

- [X] T013 Exécuter tous les tests (bin/rails test && bin/rails test:system)
- [X] T014 Valider les scénarios de quickstart.md manuellement
- [X] T015 Vérifier la cohérence visuelle avec l'écran des résultats (results/show.html.erb)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Foundational (Phase 2)**: Pas de dépendances - peut commencer immédiatement
- **User Story 1 (Phase 3)**: Dépend de Phase 2 (méthode `leaderboard`)
- **User Story 2 (Phase 4)**: Dépend de Phase 3 (section classement dans la vue)
- **User Story 3 (Phase 5)**: Dépend de Phase 3 (section classement dans la vue)
- **Polish (Phase 6)**: Dépend de toutes les user stories

### User Story Dependencies

- **User Story 1 (P1)**: Peut commencer après Phase 2 - MVP minimal
- **User Story 2 (P1)**: Dépend de US1 (modifie la même section vue)
- **User Story 3 (P2)**: Peut commencer après US1 ou en parallèle de US2

### Within Each User Story

- Tests DOIVENT être écrits et ÉCHOUER avant l'implémentation
- Story complète avant de passer à la suivante

### Parallel Opportunities

- T001 et T002 peuvent s'exécuter en parallèle (modèle et tests)
- T003 (test US1) et T007 (test US2) et T010 (test US3) peuvent être écrits en parallèle
- US2 et US3 peuvent être travaillées en parallèle après US1

---

## Parallel Example: Phase 2

```bash
# Lancer en parallèle:
Task T001: "Créer la méthode Team#leaderboard dans app/models/team.rb"
Task T002: "Créer les tests unitaires dans test/models/team_test.rb"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Compléter Phase 2: Foundational (méthode `leaderboard`)
2. Compléter Phase 3: User Story 1 (affichage basique)
3. **STOP et VALIDER**: Tester US1 indépendamment
4. Déployer/démo si prêt

### Incremental Delivery

1. Compléter Phase 2 → Méthode ready
2. Ajouter US1 → Tester → Démo (MVP! classement visible)
3. Ajouter US2 → Tester → Démo (médailles ajoutées)
4. Ajouter US3 → Tester → Démo (message équipes vides)
5. Chaque story ajoute de la valeur sans casser les précédentes

---

## Notes

- La méthode `Team#leaderboard` réutilise le pattern de `Game#ranking` pour les ex aequo
- L'affichage des médailles suit le pattern de `app/views/results/show.html.erb`
- Pas de migration de base de données (calcul à la volée, FR-006)
- Taille typique: 2-20 membres, 0-50 parties ⇒ performance acceptable sans cache
