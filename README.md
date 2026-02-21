# 🎵 HitGuessr

![Ruby](https://img.shields.io/badge/Ruby-3.4.6-red?logo=ruby)
![Rails](https://img.shields.io/badge/Rails-8.1-red?logo=rubyonrails)
![Tailwind CSS](https://img.shields.io/badge/Tailwind-4.x-38B2AC?logo=tailwindcss)
![SQLite](https://img.shields.io/badge/SQLite-3-003B57?logo=sqlite)
![License](https://img.shields.io/badge/License-MIT-green)

**A multiplayer music guessing game where friends try to identify who submitted which song.**

[Features](#-features) • [Quick Start](#-quick-start) • [Gameplay](#-gameplay) • [Tech Stack](#-tech-stack) • [API](#-api-routes) • [Changelog](#-changelog) • [Development](#-development)

---

## ✨ Features

- 🎧 **Team-based gameplay** — Create teams, invite friends, and play together
- 🎵 **Music proposals** — Submit YouTube or any music URL anonymously
- 🤔 **Guessing phase** — Try to match each song to its submitter
- 🚪 **Self-leave team** — A member can quit their team with confirmation (organizer cannot leave their own team)
- 🏆 **Leaderboard** — Scores and rankings with tie handling
- 👤 **User authentication** — Secure sign-up/login with Devise
- 🌙 **Dark neon theme** — Stylish music-inspired UI with glowing effects
- 📱 **Responsive design** — Works on desktop and mobile

---

## 🚀 Quick Start

### Prerequisites

- **Ruby 3.4.6** (check with `ruby -v`)
- **Bundler** (`gem install bundler`)
- **Node.js** (for Tailwind CSS compilation)

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/hitguessr.git
cd hitguessr

# Install dependencies
bundle install

# Setup database (creates, migrates, and seeds)
bin/rails db:setup

# Start the development server
bin/dev
```

The app will be available at **<http://localhost:3000>**

### Demo Account

After seeding, you can log in with:

| Email                 | Password       |
| --------------------- | -------------- |
| `jean@example.com`    | `password123`  |
| `marie@example.com`   | `password123`  |
| `pierre@example.com`  | `password123`  |
| `sophie@example.com`  | `password123`  |
| `lucas@example.com`   | `password123`  |

A demo team "**Les Mélomanes**" is pre-created with a finished game showing the scoring system.

---

## 🎧 Gameplay

### Game Flow

```text
┌─────────────────────────────────────────────────────────────────────┐
│                          GAME PHASES                                │
├─────────────────┬─────────────────────┬─────────────────────────────┤
│   COLLECTING    │      GUESSING       │         FINISHED            │
│                 │                     │                             │
│  Players submit │  Players guess who  │  Scores calculated and      │
│  music URLs     │  submitted what     │  rankings displayed         │
│  (anonymous)    │                     │                             │
└────────┬────────┴──────────┬──────────┴──────────────┬──────────────┘
         │                   │                         │
    Auto or Manual      Auto or Manual            Automatic
    (all submitted)    (all guesses done)        after all guesses
```

### Roles

| Role          | Permissions                                                              |
| ------------- | ------------------------------------------------------------------------ |
| **Organizer** | Create team, add/remove members, start games, control phase transitions  |
| **Player**    | Submit music proposals, make guesses, view results                       |

> Note: The organizer is also a player and participates in the game.

### Phase Transitions

- **Automatic**: When 100% of players have submitted, the game progresses automatically
- **Manual**: The organizer can also manually advance phases at any time
- Players are notified when automatic transitions occur

### Rules

1. **One proposal per player** — Each player submits exactly one music URL per game
2. **No duplicates** — The same URL cannot be submitted twice in the same game
3. **Anonymous proposals** — Players cannot see others' submissions during collection
4. **Complete guesses** — All proposals must be matched to a player to submit guesses
5. **No self-guessing** — Players cannot guess their own proposal (excluded automatically)

### Scoring

- **+1 point** for each correct guess
- **Ties** — Players with equal scores share the same rank
- **Missing participation** — Players who don't submit proposals or guesses score 0

---

## 🛠 Tech Stack

| Layer               | Technology                                          |
| ------------------- | --------------------------------------------------- |
| **Framework**       | Ruby on Rails 8.1                                   |
| **Database**        | SQLite 3 (development), configurable for production |
| **Authentication**  | Devise 5.0                                          |
| **Frontend**        | Hotwire (Turbo + Stimulus)                          |
| **CSS**             | Tailwind CSS 4 with custom neon theme               |
| **Asset Pipeline**  | Propshaft + Importmap                               |
| **Background Jobs** | Solid Queue                                         |
| **Caching**         | Solid Cache                                         |
| **WebSockets**      | Solid Cable                                         |
| **Deployment**      | Kamal + Docker                                      |

---

## 📊 Data Model

```text
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│    User     │       │    Team     │       │    Game     │
├─────────────┤       ├─────────────┤       ├─────────────┤
│ id          │◄──────│ organizer_id│       │ id          │
│ email       │       │ name        │◄──────│ team_id     │
│ name        │       └─────────────┘       │ status      │
│ password    │              │              │ started_at  │
└─────────────┘              │              │ finished_at │
      │                      │              └─────────────┘
      │              ┌───────┴───────┐            │
      ▼              ▼               │            ▼
┌─────────────┐                      │    ┌─────────────┐
│ Membership  │                      │    │  Proposal   │
├─────────────┤                      │    ├─────────────┤
│ user_id     │──────────────────────┼────│ player_id   │
│ team_id     │                      │    │ game_id     │
└─────────────┘                      │    │ url         │
                                     │    └─────────────┘
                                     │          │
                                     │          ▼
                                     │    ┌─────────────┐
                                     │    │   Guess     │
                                     │    ├─────────────┤
                                     └────│ player_id   │
                                          │ proposal_id │
                                          │ guessed_    │
                                          │  author_id  │
                                          └─────────────┘
```

### Game Statuses

| Status       | Value | Description                              |
| ------------ | ----- | ---------------------------------------- |
| `collecting` | 0     | Players are submitting music URLs        |
| `guessing`   | 1     | Players are guessing who submitted what  |
| `finished`   | 2     | Game ended, scores displayed             |

---

## 🔗 API Routes

### Authentication (Devise)

| Method | Path                    | Description       |
| ------ | ----------------------- | ----------------- |
| GET    | `/users/sign_in`        | Login page        |
| POST   | `/users/sign_in`        | Create session    |
| DELETE | `/users/sign_out`       | Logout            |
| GET    | `/users/sign_up`        | Registration page |
| POST   | `/users`                | Create account    |
| GET    | `/users/password/new`   | Forgot password   |

### Teams

| Method | Path              | Description       |
| ------ | ----------------- | ----------------- |
| GET    | `/teams`          | List user's teams |
| GET    | `/teams/new`      | New team form     |
| POST   | `/teams`          | Create team       |
| GET    | `/teams/:id`      | Show team details |
| GET    | `/teams/:id/edit` | Edit team form    |
| PATCH  | `/teams/:id`      | Update team       |
| DELETE | `/teams/:id`      | Delete team       |

### Memberships

| Method | Path                              | Description           |
| ------ | --------------------------------- | --------------------- |
| POST   | `/teams/:team_id/memberships`     | Add member (by email) |
| DELETE | `/teams/:team_id/memberships/:id` | Remove member         |
| DELETE | `/teams/:team_id/leave`           | Leave current team    |

### Games

| Method | Path                        | Description                  |
| ------ | --------------------------- | ---------------------------- |
| GET    | `/teams/:team_id/games`     | List team's games            |
| POST   | `/teams/:team_id/games`     | Start new game               |
| GET    | `/games/:id`                | Show game state              |
| PATCH  | `/games/:id/start_guessing` | Transition to guessing phase |
| PATCH  | `/games/:id/finish`         | End the game                 |

### Proposals

| Method | Path                            | Description          |
| ------ | ------------------------------- | -------------------- |
| GET    | `/games/:game_id/proposals/new` | Submit proposal form |
| POST   | `/games/:game_id/proposals`     | Create proposal      |
| GET    | `/games/:game_id/proposals/:id` | View proposal        |

### Guesses

| Method | Path                          | Description        |
| ------ | ----------------------------- | ------------------ |
| GET    | `/games/:game_id/guesses/new` | Guessing form      |
| POST   | `/games/:game_id/guesses`     | Submit all guesses |

### Results

| Method | Path                      | Description            |
| ------ | ------------------------- | ---------------------- |
| GET    | `/games/:game_id/results` | View scores & rankings |

---

## 🧑‍💻 Development

### Running the Server

```bash
# Development mode with Tailwind watch
bin/dev

# Or separately:
bin/rails server
bin/rails tailwindcss:watch
```

### Database Commands

```bash
# Create database
bin/rails db:create

# Run migrations
bin/rails db:migrate

# Seed demo data
bin/rails db:seed

# Reset everything (drop + create + migrate + seed)
bin/rails db:reset

# Full setup
bin/setup
```

### Testing

```bash
# Run all tests
bin/rails test

# Run system tests
bin/rails test:system

# Run specific test file
bin/rails test test/models/game_test.rb
```

### Code Quality

```bash
# Run Rubocop linter
bin/rubocop

# Security audit
bin/brakeman
bin/bundler-audit
```

### Console

```bash
# Rails console
bin/rails console

# Example: Create a user
User.create!(name: "Test", email: "test@example.com", password: "password123")

# Example: View game ranking
Game.last.ranking
```

---

## 🐳 Docker Deployment

### Build and Run

```bash
# Build the image
docker build -t hitguessr .

# Run the container
docker run -d -p 80:80 \
  -e RAILS_MASTER_KEY=$(cat config/master.key) \
  --name hitguessr \
  hitguessr
```

### With Kamal

```bash
# Setup (first time)
bin/kamal setup

# Deploy
bin/kamal deploy

# View logs
bin/kamal logs
```

---

## 📁 Project Structure

```text
hitguessr/
├── app/
│   ├── controllers/      # Request handling
│   ├── models/           # Business logic
│   ├── views/            # ERB templates
│   ├── assets/
│   │   └── tailwind/     # Custom CSS with neon theme
│   └── javascript/       # Stimulus controllers
├── config/
│   ├── routes.rb         # URL routing
│   ├── locales/          # i18n (French)
│   └── initializers/     # Devise, etc.
├── db/
│   ├── migrate/          # Database migrations
│   ├── schema.rb         # Current schema
│   └── seeds.rb          # Demo data
├── specs/                # Feature specifications
│   └── 001-hitguessr-gameplay/
│       ├── spec.md       # Full feature spec
│       └── data-model.md # Entity definitions
└── test/                 # Test suite
```

---

## 🌐 Localization

The app is localized in **French** by default. Translation files are in `config/locales/`:

- `fr.yml` — General translations
- `devise.fr.yml` — Authentication messages

---

## 📋 Changelog

### v1.2.0 *(February 21, 2026)*

- 🚪 **Self-leave team** — A member can leave a team from the team header with a `Quitter` confirmation button, while organizers are prevented from leaving their own team and leave is blocked during active games ([#009](specs/009-self-leave-team/spec.md))
- ✍️ **Conjugation/pluralization fixes (FR)** — Corrected French plural forms in team stats display (e.g. `membre` → `membres`)
- ✍️ **Emoji update** — Changed gameplay emoji from 🎮 to 🎧 for consistency

### v1.1.0 *(February 15, 2026)*

- ✨ **Player guess status board during guessing phase** — See who has submitted their guesses and who is still pending ([#006](specs/006-player-guess-status/spec.md))
- ⚡ **Automatic phase progression** — Game advances automatically when 100% of players have submitted their proposals or guesses ([#007](specs/007-auto-phase-progression/spec.md))
- 🎬 **YouTube video embed player** — Watch YouTube videos directly in the guessing, proposal, and results screens with automatic detection of non-embeddable videos ([#008](specs/008-youtube-embed-player/spec.md))
- 🏷️ **Version number in footer** — Display the current version number in the footer with a link to the changelog

### v1.0.0 *(February 10, 2026)* — MVP

- 🎧 **Full gameplay** — Collection, guessing, and results phases ([#001](specs/001-hitguessr-gameplay/spec.md))
- 🔒 **Single active game per team** — Prevents conflicts between simultaneous games ([#002](specs/002-single-active-game/spec.md))
- 🗑️ **Game cancellation** — Organizer can cancel an ongoing game ([#003](specs/003-cancel-active-game/spec.md))
- 🏆 **Team leaderboard** — Leaderboard with cumulative scores across all games ([#004](specs/004-team-leaderboard/spec.md))
- 📱 **Responsive design** — Interface adapted for mobile and desktop ([#005](specs/005-responsive-design/spec.md))

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📜 License

This project is licensed under the MIT License.

---

Made with ❤️ and 🎵

**[⬆ Back to top](#-hitguessr)**
