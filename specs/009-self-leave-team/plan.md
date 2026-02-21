# Implementation Plan: Quitter son équipe

**Branch**: `009-self-leave-team` | **Date**: 2026-02-21 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/009-self-leave-team/spec.md`

## Summary

Permettre à un membre non organisateur de quitter son équipe en auto-service, tout en empêchant strictement l'organisateur (`team.organizer_id`) de quitter sa propre équipe, et en bloquant l'action si une partie est active. L'implémentation s'appuie sur une action dédiée côté `MembershipsController`, un bouton `Quitter` sur la page équipe reprenant style/position de `Supprimer`, une confirmation utilisateur avec texte exact, des tests système/routing ciblés, et une mise à jour du README global + changelog.

## Technical Context

**Language/Version**: Ruby 3.4.6, Rails 8.1.x  
**Primary Dependencies**: Rails, Devise, Turbo, Stimulus, Tailwind CSS (tailwindcss-rails), SQLite3  
**Storage**: SQLite (dev/test), ActiveRecord  
**Testing**: Minitest + Rails system tests (Capybara + Selenium), tests contrôleurs/intégration Rails  
**Target Platform**: Application web serveur (macOS/Linux en dev, déploiement Docker/Kamal)  
**Project Type**: Application web Rails monolithique  
**Performance Goals**: Retour utilisateur (flash succès/refus) en < 2s dans au moins 95% des cas (SC-003)  
**Constraints**:

- Interdiction basée uniquement sur `team.organizer_id`
- Refus si partie active (`collecting` ou `guessing`)
- Redirection succès vers `teams#index`
- Action auto-service limitée à `current_user` (pas d'ID membership piloté par client)
- Bouton libellé exact `Quitter`
- Bouton `Quitter` même style/position que `Supprimer`
- Confirmation exacte: `Êtes-vous sûr de vouloir quitter cette équipe ?`
- README global + changelog mis à jour
**Scale/Scope**: 1 flux utilisateur principal, ~9-12 fichiers impactés (routes, contrôleur, vue, locales, fixtures, tests controller/system, README, quickstart, artefacts de contrat)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Code quality: scope restreint, séparation claire contrôleur/vue/routes/tests
- [x] Testing: stratégie définie pour succès, refus organisateur, refus partie active, idempotence, sécurité auto-service
- [x] UX consistency: bouton aligné avec pattern existant (`Supprimer`), confirmation explicite, feedback flash
- [x] Performance: objectif UX (<2s) et contrôle via parcours système standard
- [x] Quality gates: exécution prévue de tests ciblés + suite CI locale (au minimum fichier/feature touché)

## Project Structure

### Documentation (this feature)

```text
specs/009-self-leave-team/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── self-leave-team.openapi.yaml
└── tasks.md
```

### Source Code (repository root)

```text
app/
├── controllers/
│   └── memberships_controller.rb
├── views/
│   └── teams/show.html.erb

config/
├── routes.rb
└── locales/fr.yml

test/
├── system/
│   └── self_leave_team_test.rb
├── controllers/
│   └── memberships_controller_test.rb
└── fixtures/
    └── memberships.yml

README.md
specs/009-self-leave-team/quickstart.md
specs/009-self-leave-team/contracts/self-leave-team.openapi.yaml
```

**Structure Decision**: Conserver la structure Rails monolithique existante; implémentation minimale et ciblée sans nouvelle couche technique.

## Phase 0: Research Plan

Questions/axes à consolider:

1. Pattern Rails recommandé pour action auto-service de sortie (route et contrôleur) sans fragiliser `destroy` organisateur.
2. Bonnes pratiques UI Turbo/`button_to` pour confirmation destructive avec texte exact.
3. Stratégie de test la plus robuste pour garantir style/position/label `Quitter` et règles métier (organisateur + partie active + idempotence).
4. Stratégie de documentation projet pour "README global + changelog" dans ce repo (section README existante vs fichier dédié).

Livrable: `research.md` avec décisions tranchées, justifications, alternatives.

## Phase 1: Design & Contracts Plan

1. Modèle de données: confirmer l'absence de migration; formaliser invariants sur `Membership`, `Team`, `Game`.
2. Contrat HTTP: définir endpoint de self-leave, statuts/réponses attendues (HTML redirect + flash), sécurité d'accès.
3. Quickstart: scénarios manuels d'acceptation alignés FR-001..FR-018.
4. Documentation produit: lister changements attendus dans README et changelog.

Livrables: `data-model.md`, `contracts/self-leave-team.openapi.yaml`, `quickstart.md`.

## Post-Design Constitution Check

- [x] Code quality: design minimal, pas de duplication majeure attendue
- [x] Testing: couverture prévue pour tous les comportements modifiés
- [x] UX consistency: exigences de libellé/style/position/confirmation explicitement contractualisées
- [x] Performance: aucune charge additionnelle notable; budget UX conservé
- [x] Quality gates: validations testées localement prévues avant revue

## Complexity Tracking

Aucune dérogation constitutionnelle identifiée à ce stade.
