# Tasks: Lecteur YouTube Embarqué en Phase de Devinette

**Input**: Design documents from `/specs/008-youtube-embed-player/`  
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, quickstart.md ✅

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Ajouter la dépendance media_embed et préparer le projet

- [X] T001 Ajouter `gem "media_embed", "~> 1.0"` dans Gemfile
- [X] T002 Exécuter `bundle install` pour installer la gem

---

## Phase 2: Foundational

**Purpose**: Infrastructure partagée - N/A pour cette feature

> Cette feature utilise l'infrastructure Rails existante. Pas de tâches fondamentales bloquantes.

**Checkpoint**: Setup complet - implémentation des user stories peut commencer

---

## Phase 3: User Story 1 - Visualiser une vidéo YouTube (Priority: P1) 🎯 MVP

**Goal**: Afficher une iframe YouTube sous le lien de proposition pendant la phase de devinette

**Independent Test**: Créer une partie avec un lien YouTube, naviguer vers la phase de devinette, vérifier que l'iframe s'affiche sous le lien avec la miniature de la vidéo (pas de lecture automatique)

### Implementation for User Story 1

- [X] T003 [P] [US1] Créer helper `youtube_url?(url)` dans app/helpers/application_helper.rb
- [X] T004 [P] [US1] Créer helper `youtube_embed(url)` dans app/helpers/application_helper.rb
- [X] T005 [US1] Modifier la vue pour afficher l'iframe sous le lien dans app/views/guesses/new.html.erb
- [X] T006 [US1] Créer tests unitaires pour les helpers dans test/helpers/application_helper_test.rb
- [X] T007 [US1] Créer test système pour l'affichage de l'iframe YouTube dans test/system/youtube_embed_test.rb (inclure: lien cliquable présent au-dessus, iframe visible en dessous)

**Checkpoint**: L'iframe YouTube s'affiche sous le lien, la vidéo ne démarre pas automatiquement

---

## Phase 4: User Story 2 - Sélecteur de joueur sous l'iframe (Priority: P1)

**Goal**: Le sélecteur de joueur reste fonctionnel et visible sous l'iframe YouTube

**Independent Test**: Vérifier que le sélecteur de joueur apparaît sous l'iframe et que la sélection fonctionne

### Implementation for User Story 2

- [X] T008 [US2] Vérifier le positionnement du sélecteur sous l'iframe dans app/views/guesses/new.html.erb
- [X] T009 [US2] Ajouter test système pour la soumission de devinette avec iframe dans test/system/youtube_embed_test.rb

**Checkpoint**: Le joueur peut visualiser la vidéo ET soumettre sa devinette

---

## Phase 5: User Story 3 - Liens non-YouTube (Priority: P2)

**Goal**: Les liens non-YouTube continuent de fonctionner normalement sans iframe

**Independent Test**: Créer une partie avec un lien Spotify, vérifier qu'aucune iframe n'apparaît

### Implementation for User Story 3

- [X] T010 [US3] Ajouter tests unitaires pour URLs non-YouTube dans test/helpers/application_helper_test.rb
- [X] T011 [US3] Ajouter test système pour lien non-YouTube dans test/system/youtube_embed_test.rb

**Checkpoint**: Les liens non-YouTube affichent uniquement le lien cliquable (comportement existant préservé)

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Validation finale et nettoyage

- [X] T012 [P] Valider les formats YouTube edge cases (Shorts, youtu.be, Music) dans test/helpers/application_helper_test.rb
- [X] T013 [P] Vérifier l'accessibilité et sécurité iframe (title, loading, allow, frameborder) manuellement ou via test
- [X] T014 [P] Vérifier le responsive design sur mobile (aspect-video Tailwind)
- [X] T015 Exécuter la validation quickstart.md manuellement
- [X] T016 Exécuter `bin/rubocop` pour linting

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - start immediately
- **US1 (Phase 3)**: Depends on Setup - core feature
- **US2 (Phase 4)**: Depends on US1 (même vue modifiée)
- **US3 (Phase 5)**: Depends on US1 (utilise les mêmes helpers)
- **Polish (Phase 6)**: Depends on all user stories

### User Story Dependencies

- **User Story 1 (P1)**: Indépendante - MVP minimal
- **User Story 2 (P1)**: Liée à US1 (positionnement dans la même vue)
- **User Story 3 (P2)**: Indépendante mais utilise les helpers de US1

### Parallel Opportunities

```bash
# Phase 1 - Sequential (2 tâches liées):
T001 → T002

# Phase 3 - Parallel helpers:
T003 && T004  # Peuvent être faits ensemble
# Puis:
T005  # Dépend de T003, T004
# Puis:
T006 && T007  # Tests en parallèle

# Phase 6 - All [P] tasks in parallel:
T012 && T013 && T014
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. ✅ Setup (T001-T002)
2. ✅ US1 Implementation (T003-T007)
3. **STOP and VALIDATE**: Test manuel avec QuickStart guide
4. Deploy/demo si prêt

### Incremental Delivery

| Milestone | Tasks | Value Delivered |
| --------- | ----- | --------------- |
| Setup | T001-T002 | Gem installée |
| MVP | T003-T007 | Iframe YouTube fonctionne |
| Complete P1 | T008-T009 | Flow devinette complet |
| Complete P2 | T010-T011 | Rétrocompatibilité validée |
| Polish | T012-T016 | Edge cases et qualité |

---

## Summary

| Metric | Value |
| ------ | ----- |
| Total tasks | 16 |
| Setup tasks | 2 |
| US1 tasks | 5 |
| US2 tasks | 2 |
| US3 tasks | 2 |
| Polish tasks | 5 |
| Parallel opportunities | 6 groupes |
| MVP scope | T001-T007 (7 tâches) |
