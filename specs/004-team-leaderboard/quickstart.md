# Quickstart: Classement général de l'équipe

**Feature**: 004-team-leaderboard  
**Date**: 2026-02-01

## Prerequisites

- Ruby (version in `.ruby-version` or Gemfile)
- SQLite3
- Node.js (for Tailwind build)
- Bundler

## Setup

```bash
# Clone and enter repo
cd hitguessr

# Install dependencies
bundle install

# Setup database (creates, migrates, seeds)
bin/rails db:setup

# Start dev server (Procfile.dev: rails + tailwind watch)
bin/dev
```

Server runs at `http://localhost:3000`.

---

## Manual Testing Steps

### Scénario 1: Classement avec parties terminées

1. **Sign up / Sign in** as a user (e.g., `organizer@example.com`).
2. **Create a team** (you become the organizer).
3. **Add 2-3 members** to the team.
4. **Play 2-3 games** to completion (status: finished).
5. Navigate to the team page: `/teams/:id`.
6. **Verify**: Section "Classement général" visible avec :
   - Tous les joueurs ayant participé
   - Scores = somme des points de toutes les parties
   - Tri décroissant par score
   - Médailles 🥇🥈🥉 pour les 3 premiers

### Scénario 2: Ex aequo

1. Créer une situation où 2 joueurs ont le même score total.
2. **Verify**: Les deux joueurs ont le même rang et la même médaille.

### Scénario 3: Équipe sans parties terminées

1. Créer une nouvelle équipe sans parties ou avec parties en cours uniquement.
2. Navigate to the team page.
3. **Verify**: Message "Aucun classement disponible" affiché.

### Scénario 4: Joueur sans participation

1. Ajouter un nouveau membre à une équipe avec des parties terminées.
2. Navigate to the team page.
3. **Verify**: Le nouveau membre n'apparaît pas dans le classement.

---

## Running Tests

```bash
# All tests
bin/rails test

# Specific test file (once implemented)
bin/rails test test/models/team_test.rb

# System tests (Capybara)
bin/rails test:system
```

---

## Useful Commands

```bash
# Rails console
bin/rails console

# Check team leaderboard
Team.first.leaderboard

# Tail logs
tail -f log/development.log
```

---

## Files to Implement / Modify

| File | Change |
| ---- | ------ |
| `app/models/team.rb` | Add `leaderboard` method |
| `app/controllers/teams_controller.rb` | Add `@leaderboard` to `show` action |
| `app/views/teams/show.html.erb` | Add leaderboard section |
| `test/models/team_test.rb` | Add leaderboard unit tests |
| `test/system/team_leaderboard_test.rb` | Add system test |
