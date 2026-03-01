# Quickstart: Randomisation de l’ordre des propositions

**Feature**: 011-randomize-guess-order  
**Date**: 2026-03-01

## Prerequisites

- Ruby 3.4.6
- Bundler
- SQLite3
- Node.js (Tailwind build)

## Setup

```bash
cd hitguessr
bundle install
bin/rails db:setup
bin/dev
```

App runs at `http://localhost:3000`.

## Manual Validation Scenarios

### Scenario A — L’ordre n’expose plus l’ordre de soumission

1. Créer une partie avec au moins 3 joueurs.
2. Soumettre les propositions dans un ordre connu (A, puis B, puis C).
3. Passer la partie en phase de devinettes.
4. Ouvrir l’écran de devinettes.
5. Vérifier que l’ordre affiché n’est pas l’ordre chronologique de soumission.

### Scenario B — Tous les joueurs voient le même ordre

1. Garder la même manche en phase de devinettes.
2. Connecter deux joueurs différents éligibles à deviner.
3. Ouvrir la page de devinettes des deux côtés.
4. Vérifier que la séquence des propositions est identique.

### Scenario C — Rechargement stable à 100%

1. Sur une manche active en devinettes, ouvrir la page `guesses/new`.
2. Recharger la page 10 fois.
3. Vérifier que la séquence affichée ne change jamais.

### Scenario D — Indépendance entre manches

1. Terminer une manche puis démarrer une nouvelle manche.
2. Reproduire des propositions avec un jeu similaire.
3. Vérifier que l’ordre affiché de la nouvelle manche est déterminé indépendamment de la précédente.

### Scenario E — Soumission tardive refusée

1. Une fois la phase de devinettes démarrée, tenter de poster une nouvelle proposition.
2. Vérifier le refus explicite et l’absence de création de proposition.

### Scenario F — Edge cases 0/1 proposition

1. Démarrer une manche avec 0 ou 1 proposition (cas de transition contrôlée).
2. Vérifier absence d’erreur applicative et comportement cohérent des écrans.

## Automated Tests To Run

```bash
bin/rails test test/models/game_test.rb
bin/rails test test/models/proposal_test.rb
bin/rails test test/controllers/guesses_controller_test.rb
bin/rails test test/system/guess_order_randomization_test.rb
```

## Test Results (T032) — 2026-03-01

```text
113 runs, 298 assertions, 0 failures, 0 errors, 0 skips
```

| Tests ajoutés | Fichier cible | Résultat |
| - | - | - |
| +5 modèle (assignation, idempotence, indépendance, helper) | `game_test.rb` | ✓ PASS |
| +5 contrôleur (ordre, stabilité, edge case) | `guesses_controller_test.rb` | ✓ PASS |
| +3 système (affichage, reload, inter-manches) | `guess_order_randomization_test.rb` | ✓ PASS |

## Performance Measurement Protocol

### Goal

- `GET /games/:game_id/guesses/new` p95 < 200ms (jusqu’à 30 propositions)
- Assignation d’ordre lors de `start_guessing!` < 100ms (jusqu’à 30 propositions)

### Procedure

1. Préparer une game avec 30 propositions valides.
2. Mesurer 20 chargements de `guesses/new` (utiliser monotonic clock côté test/runner).
3. Mesurer 20 transitions `collecting -> guessing` sur jeux de données équivalents.
4. Calculer p95 pour chaque série.
5. Valider les budgets ci-dessus.

## Performance Results (T033/T034) — 2026-03-01

**Environnement**: RAILS_ENV=test | 20 runs | 30 propositions

### T034 — `assign_guess_order!` (collecting → guessing)

| Métrique | Valeur | Budget |
| - | - | - |
| p95 | **4.03 ms** | < 100 ms |
| Avg | 3.22 ms | — |
| Status | ✓ PASS | — |

### T033 — `ordered_proposals_for_guessing` query (GET /guesses/new)

| Métrique | Valeur | Budget |
| - | - | - |
| p95 | **2.74 ms** | < 200 ms |
| Avg | 1.31 ms | — |
| Status | ✓ PASS | — |

## SC-004 Protocol Results (T035) — 2026-03-01

**Protocole simulé**: 10 joueurs × 20 manches consécutives | `RAILS_ENV=test`

| Métrique | Valeur | Critère |
| - | - | - |
| Ordres uniques sur 20 manches | **20/20** | > 1 unique |
| Transitions avec ordre différent | **19/19** | Non déterministe |
| Status | ✓ PASS | — |

> Avec 10 joueurs, 10! = 3 628 800 ordres possibles.
> Probabilité que 20 manches aient toutes le même ordre : (1/3628800)^19 ≈ 0.

## Accessibility Review

- Keyboard: radios et bouton de soumission restent atteignables au clavier.
- Readability: l’étiquetage `Proposition #n` reste clair après randomisation.
- Feedback: messages d’erreur/succès restent explicites sans changement de composant.
