# Implementation Plan: Classement général de l'équipe

**Branch**: `004-team-leaderboard` | **Date**: 2026-02-01 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/004-team-leaderboard/spec.md`

## Summary

Ajouter un classement général sur la page de l'équipe qui affiche la somme des points de chaque joueur sur toutes les parties terminées. Le classement est trié par score décroissant, affiche des médailles (🥇🥈🥉) pour le podium, et gère les ex aequo. Les scores ne sont pas persistés (calcul à la volée).

## Technical Context

**Language/Version**: Ruby 3.4.x, Rails 8.1.2  
**Primary Dependencies**: Rails, Devise (auth), Turbo/Stimulus (frontend), Tailwind CSS  
**Storage**: SQLite3 (development/test), PostgreSQL en production - Pas de nouveau stockage requis  
**Testing**: Minitest (rails test), Capybara + Selenium (system tests)  
**Target Platform**: Web (server-rendered with Hotwire)  
**Project Type**: Web application (monolith)  
**Performance Goals**: Classement affiché en < 1 seconde (SC-001)  
**Constraints**: Pas de persistance des scores cumulés (FR-006) - calcul à la volée  
**Scale/Scope**: Équipes de 2-20 membres, 0-50 parties terminées par équipe

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Code quality: scope is small, readable, and maintainable
- [x] Testing: test strategy defined for all changed behaviors
- [x] UX consistency: UI/UX alignment and accessibility checks planned
- [x] Performance: budgets and measurement plan defined
- [x] Quality gates: lint/format/CI checks identified

**Notes**:

- Code quality: Une méthode modèle (`Team#leaderboard`) + modification vue existante ; suit patterns établis
- Testing: Tests unitaires modèle + test système pour affichage
- UX: Réutilise le pattern visuel de `results/show.html.erb` (médailles, tri, mise en forme)
- Performance: Calcul agrégé sur parties terminées ; acceptable pour taille typique
- Quality gates: RuboCop, Brakeman, pipeline CI existant

## Project Structure

### Documentation (this feature)

```text
specs/004-team-leaderboard/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (N/A - no API changes)
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
app/
├── controllers/
│   └── teams_controller.rb    # Add @leaderboard to show action
├── models/
│   └── team.rb                # Add leaderboard method
├── views/
│   └── teams/
│       └── show.html.erb      # Add leaderboard section
test/
├── models/
│   └── team_test.rb           # Add leaderboard tests
└── system/
    └── team_leaderboard_test.rb  # Add system test
```

**Structure Decision**: Web application monolith (existing). No new directories needed.

## Complexity Tracking

> No constitution violations. Feature is straightforward view + model addition.

| Violation | Why Needed | Simpler Alternative Rejected Because |
| --------- | ---------- | ------------------------------------ |
| (none)    | —          | —                                    |

## Phase Outputs

| Phase | Artifact | Status |
| ----- | -------- | ------ |
| 0 | [research.md](research.md) | ✅ Complete |
| 1 | [data-model.md](data-model.md) | ✅ Complete |
| 1 | contracts/ | N/A (no API changes) |
| 1 | [quickstart.md](quickstart.md) | ✅ Complete |
| 2 | [tasks.md](tasks.md) | ✅ Complete |
