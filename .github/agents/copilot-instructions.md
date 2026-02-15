# hitguessr Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-01-31

## Active Technologies
- Ruby 3.4.x, Rails 8.1.2 + Hotwire (Turbo, Stimulus), Tailwind CSS, Devise (002-single-active-game)
- SQLite (development), ActiveRecord ORM (002-single-active-game)
- Ruby 3.4.x, Rails 8.1.2 + Rails, Devise (auth), Turbo/Stimulus (frontend), Tailwind CSS (003-cancel-active-game)
- SQLite3 (development/test), PostgreSQL en production (003-cancel-active-game)
- SQLite3 (development/test), PostgreSQL en production - Pas de nouveau stockage requis (004-team-leaderboard)
- Ruby 3.x / Rails 8.1.2 + Tailwind CSS 4.x (via tailwindcss-rails), Turbo/Stimulus (Hotwire) (005-responsive-design)
- SQLite3 (pas impacté par cette feature) (005-responsive-design)
- Ruby 3.x, Rails 8.1.2 + Turbo Rails, Stimulus, TailwindCSS (006-player-guess-status)
- SQLite3 (development/test), Active Record (006-player-guess-status)
- Ruby 3.4.6, Rails 8.1.2 + Turbo/Hotwire, Devise, SQLite3, Tailwind CSS (007-auto-phase-progression)
- SQLite3 (development), compatible PostgreSQL en production (007-auto-phase-progression)
- Ruby 3.4.x, Rails 8.1.2 + Hotwire (Turbo + Stimulus), Tailwind CSS, importmap-rails, media_embed (nouvelle) (008-youtube-embed-player)
- SQLite (development), N/A pour cette feature (pas de migration) (008-youtube-embed-player)

- Ruby 3.4.6 + Devise (authentification), TailwindCSS v4.1 (styling) (001-hitguessr-gameplay)

## Project Structure

```text
src/
tests/
```

## Commands

# Add commands for Ruby 3.4.6

## Code Style

Ruby 3.4.6: Follow standard conventions

## Recent Changes
- 008-youtube-embed-player: Added Ruby 3.4.x, Rails 8.1.2 + Hotwire (Turbo + Stimulus), Tailwind CSS, importmap-rails, media_embed (nouvelle)
- 007-auto-phase-progression: Added Ruby 3.4.6, Rails 8.1.2 + Turbo/Hotwire, Devise, SQLite3, Tailwind CSS
- 006-player-guess-status: Added Ruby 3.x, Rails 8.1.2 + Turbo Rails, Stimulus, TailwindCSS


<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
