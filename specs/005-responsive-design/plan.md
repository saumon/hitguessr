# Implementation Plan: Responsive Design

**Branch**: `005-responsive-design` | **Date**: 2026-02-01 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/005-responsive-design/spec.md`

## Summary

Adapter l'interface HitGuessr pour qu'elle soit utilisable sur tous les appareils (mobile < 640px, tablette 640-1024px, desktop > 1024px). L'application utilise déjà Tailwind CSS, donc l'implémentation consiste principalement à auditer et ajuster les classes responsive existantes dans les vues Rails/ERB, et à ajouter des patterns responsive manquants (navigation simplifiée sur mobile, cartes empilées pour les tableaux, respect de prefers-reduced-motion).

## Technical Context

**Language/Version**: Ruby 3.x / Rails 8.1.2  
**Primary Dependencies**: Tailwind CSS 4.x (via tailwindcss-rails), Turbo/Stimulus (Hotwire)  
**Storage**: SQLite3 (pas impacté par cette feature)  
**Testing**: Rails system tests (Capybara), tests d'intégration Rails  
**Target Platform**: Web (navigateurs modernes : 2 dernières versions de Chrome, Firefox, Safari, Edge)
**Project Type**: Web monolithique Rails (pas de séparation frontend/backend)  
**Performance Goals**: CLS < 0.1, transition orientation < 500ms, temps de chargement perçu < 3s sur 4G  
**Constraints**: Largeur minimale supportée 320px, zones tactiles ≥ 44x44px  
**Scale/Scope**: ~10 vues ERB à auditer/modifier (layouts, games, teams, results, proposals, home)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Code quality: scope est limité aux vues ERB et CSS Tailwind, changements atomiques par vue
- [x] Testing: system tests avec viewports différents (mobile, tablette, desktop)
- [x] UX consistency: suit les patterns Tailwind responsive standards (sm:, md:, lg:)
- [x] Performance: CLS mesuré, prefers-reduced-motion respecté
- [x] Quality gates: lint CSS/ERB, CI avec tests system multi-viewport

## Project Structure

### Documentation (this feature)

```text
specs/005-responsive-design/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # N/A (pas de changement de modèle)
├── quickstart.md        # Phase 1 output
├── contracts/           # N/A (pas d'API)
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
# Structure Rails existante (pas de modification de structure)
app/
├── assets/
│   └── tailwind/
│       └── application.css    # Styles custom + responsive utilities
├── views/
│   ├── layouts/
│   │   └── application.html.erb  # Navigation responsive
│   ├── home/
│   │   └── index.html.erb
│   ├── games/
│   │   ├── show.html.erb
│   │   ├── _collecting.html.erb
│   │   ├── _guessing.html.erb
│   │   └── _finished.html.erb
│   ├── teams/
│   │   └── *.html.erb
│   ├── results/
│   │   └── show.html.erb         # Tableaux → cartes sur mobile
│   └── proposals/
│       └── *.html.erb
└── javascript/
    └── controllers/              # Stimulus controllers si nécessaire

test/
└── system/
    └── responsive_test.rb        # Tests multi-viewport
```

**Structure Decision**: Structure Rails existante conservée. Les modifications sont limitées aux fichiers de vues ERB et au CSS Tailwind. Aucun nouveau répertoire requis.

## Complexity Tracking

> Aucune violation de la constitution détectée. La feature est purement CSS/HTML sans ajout de dépendances ou de complexité architecturale.
