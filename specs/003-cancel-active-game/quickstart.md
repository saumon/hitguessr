# Quickstart: Cancel Active Game

**Feature**: 003-cancel-active-game  
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

1. **Sign up / Sign in** as a user (e.g., `organizer@example.com`).
2. **Create a team** (you become the organizer).
3. **Start a game** for that team (status = `collecting`).
4. Navigate to the game show page: `/games/:id`.
5. As the organizer, you should see a **"Annuler la partie"** button.
6. Click the button → confirmation modal appears.
7. Confirm → game is deleted, redirected to `/teams/:team_id/games` with success notice.

### Negative cases

- **Non-organizer**: Sign in as a different user who is a team member but not organizer. The cancel button should be hidden or the action rejected (403).
- **Finished game**: Finish a game (`/games/:id/finish`) then attempt to cancel via direct DELETE request → expect 422 error.

---

## Running Tests

```bash
# All tests
bin/rails test

# Specific test file (once implemented)
bin/rails test test/controllers/games_controller_test.rb

# System tests (Capybara)
bin/rails test:system
```

---

## Useful Commands

```bash
# Rails console
bin/rails console

# Check routes
bin/rails routes | grep games

# Tail logs
tail -f log/development.log
```

---

## Files to Implement / Modify

| File | Change |
| ---- | ------ |
| `config/routes.rb` | Add `destroy` action to `resources :games` |
| `app/controllers/games_controller.rb` | Add `destroy` action with authorization |
| `app/views/games/show.html.erb` | Add cancel button with confirmation |
| `test/controllers/games_controller_test.rb` | Add tests for destroy action |
| `test/system/games_test.rb` | Add system test for cancel flow |
