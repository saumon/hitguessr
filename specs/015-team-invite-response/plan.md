# Implementation Plan: Gestion des invitations d’équipe

**Branch**: `015-team-invite-response` | **Date**: 2026-03-03 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/015-team-invite-response/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Implémenter un flux d’invitation d’équipe avec consentement explicite: l’ajout d’un membre par organisateur crée une invitation en attente (et non une adhésion active), le membre invité répond via `/teams` (accepter/refuser), et le bloc “Membres” distingue clairement actifs et en attente selon les règles de visibilité. L’implémentation s’appuie sur un modèle d’invitation dédié, des contrôleurs HTML Rails avec redirections/flash, des garde-fous d’autorisation et de concurrence (première réponse gagnante), et une couverture de tests controller + system. La livraison inclut la documentation utilisateur dans `README.md` et l’entrée de changelog `v1.3.0`.

## Technical Context

**Language/Version**: Ruby 3.4.6, Rails 8.1.2  
**Primary Dependencies**: Rails (ActiveRecord, ActionController, ActionView), Devise, Turbo/Stimulus, Tailwind CSS Rails, SQLite3  
**Storage**: SQLite (tables existantes + nouvelle table d’invitations d’équipe)  
**Testing**: Minitest (ActionDispatch::IntegrationTest + ApplicationSystemTestCase/Capybara)  
**Target Platform**: Application web Rails (desktop/mobile via navigateur moderne)
**Project Type**: Web application monolithique Rails  
**Performance Goals**: Respecter SC-003 (membre visible actif sous 5 secondes après acceptation) et SC-005 (≥95% de réponses réussies au premier essai)  
**Constraints**: Première réponse valide uniquement (atomique), aucune expiration automatique des invitations, contrôle d’accès strict (invité seul pour répondre, visibilité limitée), pas de régression des permissions existantes  
**Scale/Scope**: Flux équipe centré sur `/teams` avec changements ciblés sur modèles équipe/membre/invitation, contrôleurs, vues, tests et documentation produit

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Code quality: scope is small, readable, and maintainable
- [x] Testing: test strategy defined for all changed behaviors
- [x] UX consistency: UI/UX alignment and accessibility checks planned
- [x] Performance: budgets and measurement plan defined
- [x] Quality gates: lint/format/CI checks identified

Pré-Phase 0 (initial):

- [x] Code quality: architecture ciblée (modèle d’invitation dédié) sans couplage implicite avec `Membership`
- [x] Testing: stratégie prévue (tests contrôleur pour autorisations/états + tests système pour `/teams`)
- [x] UX consistency: réutilisation du bloc `Membres` existant et conventions de feedback flash/confirm
- [x] Performance: budgets alignés sur SC-003/SC-005 + règle atomique pour éviter retries conflictuels
- [x] Quality gates: exécution prévue de `bin/rails test`, tests système ciblés, lint existant du projet

## Project Structure

### Documentation (this feature)

```text
specs/015-team-invite-response/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
app/
├── controllers/
│   ├── teams_controller.rb
│   ├── memberships_controller.rb
│   └── invitations_controller.rb            # nouveau
├── models/
│   ├── team.rb
│   ├── membership.rb
│   └── team_invitation.rb                   # nouveau
└── views/
  └── teams/
    └── show.html.erb

config/
└── routes.rb

db/
├── migrate/
└── schema.rb

test/
├── controllers/
│   ├── memberships_controller_test.rb
│   └── invitations_controller_test.rb       # nouveau
└── system/
  └── teams_test.rb

specs/015-team-invite-response/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── contracts/

README.md                                    # feature + changelog v1.3.0
```

**Structure Decision**: Conserver le monolithe Rails existant et ajouter un flux d’invitation via `team_invitations` sans altérer la table `memberships` pour les membres actifs; ceci limite les régressions sur le gameplay et le comptage des membres.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
| --------- | ---------- | ----------------------------------- |
| None | N/A | N/A |

## Post-Design Constitution Check

- [x] Code quality: modèle `TeamInvitation` isole le nouveau comportement, responsabilités explicites
- [x] Testing: cas nominaux + edge cases couverts (autorisation, doublons, concurrence, visibilité)
- [x] UX consistency: modifications limitées au bloc “Membres” et aux actions `/teams`, style existant conservé
- [x] Performance: pas de traitement lourd; requêtes indexées et feedback utilisateur immédiat
- [x] Quality gates: exécution prévue de la suite de tests Rails ciblée + CI existante
