# Implementation Plan: Lecteur YouTube Embarqué en Phase de Devinette

**Branch**: `008-youtube-embed-player` | **Date**: 2026-02-14 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/008-youtube-embed-player/spec.md`

## Summary

Intégration d'un lecteur YouTube embarqué dans la vue de devinette pour permettre aux joueurs de visionner les vidéos directement sur HitGuessr. Utilisation de la gem `media_embed` pour détecter les liens YouTube et générer les iframes avec les options appropriées (pas d'autoplay, lazy loading).

## Technical Context

**Language/Version**: Ruby 3.4.x, Rails 8.1.2  
**Primary Dependencies**: Hotwire (Turbo + Stimulus), Tailwind CSS, importmap-rails, media_embed (nouvelle)  
**Storage**: SQLite (development), N/A pour cette feature (pas de migration)  
**Testing**: Minitest (tests unitaires et système), Capybara + Selenium  
**Target Platform**: Web (navigateurs modernes)  
**Project Type**: Web application monolithique Rails  
**Performance Goals**: Chargement page < 2s, lazy loading iframe  
**Constraints**: Pas d'autoplay, iframe responsive, accessibilité (title attribute)  
**Scale/Scope**: Impact limité à la vue guesses/new.html.erb et un helper

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Code quality: scope est petit (1 helper, 1 vue modifiée), lisible et maintenable
- [x] Testing: tests système pour vérifier l'affichage de l'iframe
- [x] UX consistency: iframe intégrée naturellement sous le lien, responsive
- [x] Performance: lazy loading, pas de JS custom lourd
- [x] Quality gates: lint/format Rails existants, CI existant

## Project Structure

### Documentation (this feature)

```text
specs/008-youtube-embed-player/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output (N/A - pas de changements data)
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (N/A - pas d'API)
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
app/
├── helpers/
│   └── application_helper.rb    # Ajout helper youtube_embed
├── views/
│   └── guesses/
│       └── new.html.erb         # Modification pour afficher l'iframe
└── javascript/
    └── controllers/             # Stimulus si besoin (optionnel)

test/
├── helpers/
│   └── application_helper_test.rb  # Tests du helper
└── system/
    └── guesses_test.rb             # Tests système iframe
```

**Structure Decision**: Application web Rails monolithique existante. Les modifications se limitent à un helper et une vue ERB.

## Complexity Tracking

> Aucune violation de la constitution - le scope est minimal et bien contenu.

## Phase Artifacts

### Phase 0: Research (✅ Complete)

- [research.md](research.md) - Décisions techniques consolidées

### Phase 1: Design & Contracts (✅ Complete)

- [data-model.md](data-model.md) - Pas de modifications DB requises
- [quickstart.md](quickstart.md) - Guide d'implémentation rapide
- `contracts/` - N/A (pas de changements API)

### Phase 2: Tasks (✅ Complete)

- [tasks.md](tasks.md) - 16 tâches générées, MVP = 7 tâches

## Status

**Plan Status**: ✅ Complete  
**Constitution Check**: ✅ All gates passed  
**Next Step**: Run `/speckit.implement` or start with T001
