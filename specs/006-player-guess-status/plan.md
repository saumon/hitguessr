# Implementation Plan: Tableau de statut des joueurs en phase de devinettes

**Branch**: `006-player-guess-status` | **Date**: 2026-02-14 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/006-player-guess-status/spec.md`

## Summary

Ajouter un tableau de statut des joueurs dans la vue de phase "devinettes" (`_guessing.html.erb`), affichant pour chaque joueur ayant soumis une proposition son statut de réponse (En attente / Devinette soumise). Le composant doit reprendre la structure visuelle du tableau existant en phase de collecte (`_collecting.html.erb`).

## Technical Context

**Language/Version**: Ruby 3.x, Rails 8.1.2  
**Primary Dependencies**: Turbo Rails, Stimulus, TailwindCSS  
**Storage**: SQLite3 (development/test), Active Record  
**Testing**: Minitest (system tests avec Capybara)  
**Target Platform**: Web (desktop et mobile, responsive design)  
**Project Type**: Web application (Rails monolith)  
**Performance Goals**: N/A (simple UI rendering)  
**Constraints**: Cohérence visuelle avec le composant existant de la phase de collecte  
**Scale/Scope**: Single partial modification + passage de variables supplémentaires

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Code quality: scope is small, readable, and maintainable
- [x] Testing: test strategy defined for all changed behaviors
- [x] UX consistency: UI/UX alignment and accessibility checks planned
- [x] Performance: budgets and measurement plan defined
- [x] Quality gates: lint/format/CI checks identified

**All gates pass.** Scope is minimal (single partial modification), design reuses existing visual patterns, testing via system tests.

## Project Structure

### Documentation (this feature)

```text
specs/006-player-guess-status/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (N/A for this feature)
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
app/
├── controllers/
│   └── games_controller.rb    # Add players_with_guesses variable
├── views/
│   └── games/
│       ├── show.html.erb      # Pass new variables to _guessing partial
│       └── _guessing.html.erb # Add player status table
└── models/
    └── game.rb               # (no changes expected)

test/
└── system/
    └── guesses_test.rb       # Add tests for player status display
```

**Structure Decision**: Rails monolith standard layout. Modification localisée au partial `_guessing.html.erb` et au controller `games_controller.rb` pour passer les variables nécessaires.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

*N/A - No violations. Feature is minimal in scope.*
