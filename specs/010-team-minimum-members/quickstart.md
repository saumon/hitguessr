# Quickstart: Minimum Team Members to Start a Game

**Feature**: 010-team-minimum-members  
**Date**: 2026-02-21

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

### Scenario A — Organizer can start game with exactly 3 members

1. Sign in as a team organizer.
2. Ensure the team has exactly 3 members (including organizer if applicable).
3. Go to team page and click `Lancer une partie`.
4. Confirm game is created and success message is shown.

### Scenario B — Organizer can start game with more than 3 members

1. Ensure the team has 4+ members.
2. Start a game.
3. Confirm game is created successfully.

### Scenario C — Organizer is blocked with 2 members

1. Ensure the team has exactly 2 members.
2. Attempt to start a game.
3. Confirm explicit refusal message indicating 3 members minimum.
4. Confirm no new game record is created.

### Scenario D — Concurrency safety

1. Prepare team at 3 members.
2. Trigger launch while removing one member nearly simultaneously.
3. Confirm transactional final check prevails.
4. Confirm no invalid game gets created if team drops below 3.

### Scenario E — Existing rules still apply

1. Use a team already having an active game.
2. Attempt to start another game with 3+ members.
3. Confirm refusal remains based on existing active-game rule.

## Automated Tests To Run

```bash
bin/rails test test/models/game_test.rb
bin/rails test test/controllers/games_controller_test.rb
bin/rails test test/system/teams_test.rb
```

## Documentation Validation

1. Verify feature description is present in `README.md`.
2. Verify changelog entry in English includes spec reference `#010`.

## Accessibility Review (T027)

- Keyboard: launch controls are reachable by tab order in team and new game pages.
- Focus visibility: default focus indicators remain visible on actionable launch controls.
- Contrast: disabled launch states keep readable text against background in dark theme.
- Feedback readability: explicit refusal/success messages are short and understandable.

Outcome: primary launch flow passes baseline accessibility checks for this feature scope.

## SC-003 Measurement Protocol (T028)

1. Use `bin/rails runner -e test` with an integration session authenticated as organizer.
2. Execute 20 launch attempts alternating:
	- Eligible team (3 members) → success path.
	- Ineligible team (2 members) → refusal path.
3. Measure elapsed time per request using `Process.clock_gettime(Process::CLOCK_MONOTONIC)`.
4. Compute:
	- p95 latency (milliseconds)
	- percentage of attempts with latency `<= 2000ms`
5. Pass condition for SC-003:
	- p95 under 2000ms
	- at least 95% of attempts under 2000ms
