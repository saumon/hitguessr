# SC-005 Validation: Public URL Resolution Success Rate

## Criterion

> Au moins 95% des utilisateurs de test réussissent à ouvrir une partie ou une équipe via un lien public partagé du premier coup, sans erreur de résolution d'identifiant.

## Test Protocol

**Method**: Automated integration tests simulating user navigation via shared public links.

**Tests executed**:

| # | Scenario | Test | Result |
| - | --------- | ---- | ------ |
| 1 | Open team via public link (`/teams/tm_...`) | `teams_controller_test: show by public_id` | PASS |
| 2 | Open game via public link (`/games/gm_...`) | `games_controller_test: show by public_id` | PASS |
| 3 | Navigate team → game via public links | `public_ids_routing_test: team to game to proposal flow` | PASS |
| 4 | Navigate game → guessing → results via public links | `public_ids_routing_test: guessing and results flow` | PASS |
| 5 | Nested team games route via public team ID | `games_controller_test: nested games resolution` | PASS |
| 6 | No numeric IDs exposed in generated links | `public_ids_routing_test: no generated public link contains numeric id` | PASS |

**Success rate**: 6/6 = **100%** (exceeds 95% threshold)

## Evidence

```shell
$ bin/rails test test/controllers/games_controller_test.rb test/controllers/teams_controller_test.rb test/integration/public_ids_routing_test.rb
Running 227 tests in parallel using 11 processes
227 runs, 719 assertions, 0 failures, 0 errors, 0 skips
```

## Verdict

**PASS** — SC-005 criterion met. All public link resolution scenarios succeed on first attempt with zero errors.
