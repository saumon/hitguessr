# Implementation Plan: Annulation d'une partie active

**Branch**: `003-cancel-active-game` | **Date**: 2026-02-01 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/003-cancel-active-game/spec.md`

## Summary

Permettre à l'organisateur d'une équipe d'annuler (supprimer définitivement) une partie active dont il est propriétaire. L'annulation déclenche une suppression en cascade (game → proposals → guesses) après confirmation explicite de l'utilisateur.

## Technical Context

**Language/Version**: Ruby 3.4.x, Rails 8.1.2  
**Primary Dependencies**: Rails, Devise (auth), Turbo/Stimulus (frontend), Tailwind CSS  
**Storage**: SQLite3 (development/test), PostgreSQL en production  
**Testing**: Minitest (rails test), Capybara + Selenium (system tests)  
**Target Platform**: Web (server-rendered with Hotwire)  
**Project Type**: Web application (monolith)  
**Performance Goals**: Deletion completes in < 500ms for typical game size (< 50 proposals)  
**Constraints**: Must not block UI; confirmation required before destructive action  
**Scale/Scope**: Small-to-medium user base; single active game per team at a time

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Code quality: scope is small, readable, and maintainable
- [x] Testing: test strategy defined for all changed behaviors
- [x] UX consistency: UI/UX alignment and accessibility checks planned
- [x] Performance: budgets and measurement plan defined
- [x] Quality gates: lint/format/CI checks identified

**Notes**:

- Code quality: Single new controller action + view button; follows existing patterns.
- Testing: Controller tests + system test for confirmation flow.
- UX: Uses existing Turbo confirmation pattern; accessible button with clear label.
- Performance: Cascade delete is O(n) on proposals/guesses; acceptable for typical game size.
- Quality gates: RuboCop, Brakeman, existing CI pipeline.

## Project Structure

### Documentation (this feature)

```text
specs/003-cancel-active-game/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── cancel-game.md
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
app/
├── controllers/
│   └── games_controller.rb    # Add destroy action
├── models/
│   └── game.rb                # No changes (cascade already defined)
├── views/
│   └── games/
│       └── show.html.erb      # Add cancel button
config/
└── routes.rb                  # Add destroy route
test/
├── controllers/
│   └── games_controller_test.rb  # Add destroy tests
└── system/
    └── games_test.rb             # Add cancel flow system test
```

**Structure Decision**: Web application monolith (existing). No new directories needed.

## Complexity Tracking

> No constitution violations. Feature is straightforward CRUD extension.

| Violation | Why Needed | Simpler Alternative Rejected Because |
| --------- | ---------- | ------------------------------------ |
| (none)    | —          | —                                    |

## Phase Outputs

| Phase | Artifact | Status |
| ----- | -------- | ------ |
| 0 | [research.md](research.md) | ✅ Complete |
| 1 | [data-model.md](data-model.md) | ✅ Complete |
| 1 | [contracts/cancel-game.md](contracts/cancel-game.md) | ✅ Complete |
| 1 | [quickstart.md](quickstart.md) | ✅ Complete |
| 2 | [tasks.md](tasks.md) | ✅ Complete |
