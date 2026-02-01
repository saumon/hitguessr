# Implementation Plan: Limite d'une partie active par organisateur

**Branch**: `002-single-active-game` | **Date**: 2026-01-31 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-single-active-game/spec.md`

## Summary

Empêcher un organisateur de lancer plus d'une partie active à la fois pour une équipe donnée. Une partie est considérée "active" si son statut est `collecting` ou `guessing`. L'approche technique consiste à ajouter une validation custom sur le modèle `Game` qui vérifie qu'aucune autre partie active n'existe pour la même équipe, et à adapter l'interface utilisateur pour afficher un bouton désactivé avec tooltip explicatif lorsqu'une partie est en cours.

## Technical Context

**Language/Version**: Ruby 3.4.x, Rails 8.1.2  
**Primary Dependencies**: Hotwire (Turbo, Stimulus), Tailwind CSS, Devise  
**Storage**: SQLite (development), ActiveRecord ORM  
**Testing**: Minitest (Rails default), fixtures  
**Target Platform**: Web application (serveur Linux, navigateurs modernes)  
**Project Type**: Monolithe Rails (MVC)  
**Performance Goals**: < 100ms pour la création de partie avec validation  
**Constraints**: Pas de race condition sur la création de parties simultanées  
**Scale/Scope**: Application mono-équipe par session, ~10-50 membres par équipe

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Code quality: scope is small, readable, and maintainable
- [x] Testing: test strategy defined for all changed behaviors
- [x] UX consistency: UI/UX alignment and accessibility checks planned
- [x] Performance: budgets and measurement plan defined
- [x] Quality gates: lint/format/CI checks identified

**Initial Notes (Pre-Phase 0)**:

- Code quality: ajout d'une validation custom simple + helper pour la vue
- Testing: tests unitaires pour la validation modèle + test système pour l'UX
- UX consistency: bouton désactivé avec tooltip suit les patterns existants (Tailwind)
- Performance: validation SQL simple (COUNT avec WHERE), < 1ms impact
- Quality gates: CI Rails existant (RuboCop, Minitest)

**Post-Design Re-evaluation (Phase 1 Complete)**:

- ✅ Code quality: Design confirmé - scope limité (2 modèles, 1 vue, pas de nouveau controller)
- ✅ Testing: Strategy documentée dans research.md et quickstart.md
- ✅ UX consistency: Pattern tooltip avec `group-hover` Tailwind validé
- ✅ Performance: Query `EXISTS` sur index existant, impact négligeable
- ✅ Quality gates: Aucun nouveau outil requis, CI existant suffisant

**Verdict**: ✅ PASS - Prêt pour Phase 2 (tasks)

## Project Structure

### Documentation (this feature)

```text
specs/002-single-active-game/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (N/A - no new API endpoints)
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
app/
├── models/
│   ├── game.rb          # Validation custom: une seule partie active par équipe
│   └── team.rb          # Helper method: active_game, has_active_game?
└── views/
    └── teams/
        └── show.html.erb    # Bouton conditionnel avec tooltip

test/
├── models/
│   ├── game_test.rb     # Tests validation unicité partie active
│   └── team_test.rb     # Tests helper methods
└── system/
    └── single_active_game_test.rb  # Test E2E du comportement
```

**Structure Decision**: Monolithe Rails existant, modifications ciblées dans les couches Model/View/Controller sans ajout de nouveaux fichiers majeurs.

## Complexity Tracking

> Aucune violation du Constitution Check - pas de justification nécessaire.
