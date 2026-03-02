# Implementation Plan: Autonomie des membres d'équipe

**Branch**: `012-team-member-autonomy` | **Date**: 2026-03-01 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/012-team-member-autonomy/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Étendre les permissions de progression de partie (`lancer`, `passer aux devinettes`, `terminer`) à tous les membres de l’équipe, organisateur inclus, tout en conservant `annuler la partie` et la gestion des membres comme actions exclusives organisateur. L’implémentation s’appuie sur les contrôles serveur existants (vérification rôle + appartenance au moment d’exécution), aligne l’UI avec masquage strict des actions non autorisées, formalise le refus concurrent explicite sur transition déjà consommée, et inclut la documentation produit dans [README.md](../../README.md) avec entrée changelog `v1.2.3`.

## Technical Context

**Language/Version**: Ruby 3.4.6, Rails 8.1.x  
**Primary Dependencies**: Rails, ActiveRecord, Devise, Turbo, Stimulus, Tailwind CSS, SQLite3  
**Storage**: SQLite (dev/test) via ActiveRecord (pas de nouveau stockage externe)  
**Testing**: Minitest (`test/models`, `test/controllers`, `test/system`)  
**Target Platform**: Application web Rails (desktop + mobile, navigateurs modernes)
**Project Type**: Monolithe web Rails  
**Performance Goals**:

- 95% des actions de progression autorisées aboutissent à un changement d’état visible en < 2s (SC-004)
- 0 double transition concurrente appliquée sur lot de 200 transitions testées (SC-005)
- 95% des utilisateurs testeurs identifient leurs actions autorisées en < 10s (SC-003)
- p95 des endpoints de transition (`POST /teams/:team_id/games`, `PATCH /games/:id/start_guessing`, `PATCH /games/:id/finish`) < 300ms en conditions nominales (équipe <= 10 membres)
**Constraints**:
- Conserver les routes et patterns de redirection HTML existants
- Vérification permissions au moment d’exécution (pas uniquement UI)
- Masquage UI des actions non autorisées (pas de bouton désactivé)
- `cancel game` + gestion des membres strictement organisateur
- Documentation obligatoire: mise à jour feature dans README + entrée changelog `v1.2.3`
**Scale/Scope**: 1 flux permissions gameplay, ~8-12 fichiers applicatifs + tests ciblés + documentation produit

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Code quality: changements circonscrits aux contrôles d’autorisation et à l’exposition d’actions UI
- [x] Testing: stratégie définie sur modèle/contrôleur/système pour permissions, transitions et concurrence
- [x] UX consistency: réutilisation des composants existants + masquage cohérent des actions interdites
- [x] Performance: objectifs SC-004/SC-005 traduits en budget + protocole de mesure défini
- [x] Quality gates: exécution prévue `bin/rails test`, `bin/rubocop`, `bin/brakeman`
- [x] Accessibility: revue interaction/visuel planifiée sur les flux primaires équipe/partie

## Project Structure

### Documentation (this feature)

```text
specs/012-team-member-autonomy/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── team-member-autonomy.openapi.yaml
└── tasks.md
```

### Source Code (repository root)

```text
app/
├── controllers/
│   ├── games_controller.rb
│   └── memberships_controller.rb
├── models/
│   ├── game.rb
│   └── team.rb
└── views/
    ├── teams/show.html.erb
    └── games/
        ├── _collecting.html.erb
        ├── _guessing.html.erb
        └── _finished.html.erb

config/
└── routes.rb

test/
├── models/
│   └── game_test.rb
├── controllers/
│   ├── games_controller_test.rb
│   └── memberships_controller_test.rb
└── system/
    └── teams_test.rb

README.md
```

**Structure Decision**: Conserver le monolithe Rails existant, sans nouvelle couche d’architecture. Modifier uniquement les règles d’autorisation serveurs et les conditions d’affichage UI, puis couvrir via tests Minitest ciblés et documentation produit dans [README.md](../../README.md) (features + changelog `v1.2.3`).

## Phase 0: Research Plan

1. Définir le modèle d’autorisation cible pour les transitions de jeu: membre (incluant organisateur) vs actions réservées organisateur.
2. Définir la stratégie de contrôle serveur uniforme (UI contournée incluse) et de retour UX par redirection + message explicite.
3. Définir la gestion déterministe des transitions concurrentes avec refus explicite de la seconde transition.
4. Définir les impacts UX minimaux (actions cachées selon rôle) en conservant les composants existants.
5. Définir la couverture de tests (modèle/contrôleur/système) et budgets de performance alignés constitution.
6. Définir la mise à jour documentaire produit: section features/roles et changelog `v1.2.3` dans [README.md](../../README.md).
7. Définir un protocole mesurable SC-003 (temps d’identification des permissions) et une revue accessibilité explicite.

Livrable: `research.md` (décisions, rationales, alternatives).

## Phase 1: Design & Contracts Plan

1. Formaliser les entités et invariants d’autorisation/transition dans `data-model.md`.
2. Spécifier les contrats HTTP impactés dans `contracts/team-member-autonomy.openapi.yaml`.
3. Définir les scénarios de validation manuelle et commandes de test dans `quickstart.md`.
4. Inclure le périmètre documentaire obligatoire (README + changelog `v1.2.3`) dans les étapes de validation.
5. Mettre à jour le contexte agent via script Speckit.
6. Prévoir la vérification des budgets performance dans CI (ou justification explicite de non-faisabilité).

Livrables: `data-model.md`, `contracts/team-member-autonomy.openapi.yaml`, `quickstart.md`, contexte agent mis à jour.

## Post-Design Constitution Check

- [x] Code quality: responsabilité claire des règles d’accès (serveur) et des affordances UI (vue)
- [x] Testing: plan couvre permissions, transitions invalides, concurrence et non-régression actions organisateur
- [x] UX consistency: aucune nouvelle UI; adaptation conditionnelle des actions existantes uniquement
- [x] Performance: budgets explicités + protocole de mesure des transitions/documenté dans quickstart + stratégie de vérification CI
- [x] Quality gates: lint/tests/scans sécurité identifiés avant revue
- [x] Accessibility: revue clavier/contraste/feedback textuel définie dans quickstart et tasks

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
| --------- | ---------- | ----------------------------------- |

Aucune violation constitutionnelle nécessitant dérogation.
