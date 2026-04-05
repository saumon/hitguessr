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
- Ruby 3.4.6, Rails 8.1.x + Rails, Devise, Turbo, Stimulus, Tailwind CSS (tailwindcss-rails), SQLite3 (009-self-leave-team)
- SQLite (dev/test), ActiveRecord (009-self-leave-team)
- Ruby 3.4.6, Rails 8.1.x + Rails, ActiveRecord, Devise, Turbo, Stimulus, Tailwind CSS, SQLite3 (010-team-minimum-members)
- SQLite (dev/test), ActiveRecord (migration pour persistance d’ordre de devinette) (011-randomize-guess-order)
- SQLite (dev/test) via ActiveRecord (pas de nouveau stockage externe) (012-team-member-autonomy)
- Ruby 3.4.6, Rails 8.1.2, ERB + Hotwire/Stimulus (importmap) + rails, stimulus-rails, turbo-rails, tailwindcss-rails, devise (013-duplicate-guess-warning)
- SQLite via ActiveRecord (pas de changement de schéma prévu) (013-duplicate-guess-warning)
- Ruby 3.4.6, Rails 8.1.2, ERB + Hotwire/Stimulus (importmap) + rails, devise, turbo-rails, stimulus-rails, tailwindcss-rails (014-proposal-edit-window)
- SQLite via ActiveRecord (aucune migration prévue) (014-proposal-edit-window)
- Ruby 3.4.6, Rails 8.1.2 + Rails (ActiveRecord, ActionController, ActionView), Devise, Turbo/Stimulus, Tailwind CSS Rails, SQLite3 (015-team-invite-response)
- SQLite (tables existantes + nouvelle table d’invitations d’équipe) (015-team-invite-response)
- Ruby 3.4.6, Rails 8.1.x + Rails (ActionView/ERB), Devise, Turbo (`button_to`), Tailwind CSS 4, I18n (016-reposition-leave-team-button)
- SQLite via ActiveRecord (aucun changement de schéma) (016-reposition-leave-team-button)
- Ruby 3.4.6 + Rails 8.1.2 + ActiveRecord, ActionController, Devise, SecureRandom (017-public-url-ids)
- SQLite (dev/test), schema ActiveRecord (017-public-url-ids)
- Ruby 3.4.6 + Rails 8.1.2 + ActiveRecord, ActionController, Devise, SQLite adapter, I18n (018-team-game-numbering)
- SQLite via schema ActiveRecord (dev/test), RDBMS compatible en production (018-team-game-numbering)
- Ruby 3.4.6 + Rails 8.1.3 + Devise 5.0 (Confirmable), Action Mailer, Active Record, Hitguessr::MailerSettings (001-account-email-verification)
- SQLite via Active Record (dev/test), compatible RDBMS en production (001-account-email-verification)

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
- 001-account-email-verification: Added Ruby 3.4.6 + Rails 8.1.3 + Devise 5.0 (Confirmable), Action Mailer, Active Record, Hitguessr::MailerSettings
- 018-team-game-numbering: Added Ruby 3.4.6 + Rails 8.1.2 + ActiveRecord, ActionController, Devise, SQLite adapter, I18n
- 017-public-url-ids: Added Ruby 3.4.6 + Rails 8.1.2 + ActiveRecord, ActionController, Devise, SecureRandom


<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
