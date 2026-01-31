# Quickstart: HitGuessr

**Date**: 2026-01-31  
**Branch**: `001-hitguessr-gameplay`

Guide de démarrage rapide pour développer HitGuessr.

---

## Prérequis

- Ruby 3.4.6
- Rails 8.1.2
- SQLite 3.x (inclus avec macOS/Linux)
- Git

### Vérification

```bash
ruby -v    # => ruby 3.4.6
rails -v   # => Rails 8.1.2
sqlite3 --version
```

---

## Création du projet

```bash
# Créer l'application Rails avec TailwindCSS
rails new hitguessr --css tailwind --database sqlite3

cd hitguessr
```

---

## Installation des dépendances

### Gemfile

Ajouter au `Gemfile`:

```ruby
# Authentication
gem "devise", "~> 5.0"

# Development/Test
group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
```

```bash
bundle install
```

---

## Configuration Devise

```bash
# Installer Devise
rails generate devise:install

# Générer le modèle User
rails generate devise User

# Ajouter le champ name
rails generate migration AddNameToUsers name:string
```

Modifier la migration pour `name`:

```ruby
# db/migrate/xxx_add_name_to_users.rb
class AddNameToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string, null: false, default: ""
  end
end
```

```bash
rails db:migrate
```

### Configuration Devise pour Turbo

```ruby
# config/initializers/devise.rb
Devise.setup do |config|
  config.responder.error_status = :unprocessable_content
  config.responder.redirect_status = :see_other
  # ... autres configs
end
```

---

## Génération des modèles

```bash
# Team
rails generate model Team name:string organizer:references

# Membership (join table)
rails generate model Membership user:references team:references

# Game
rails generate model Game team:references status:integer

# Proposal
rails generate model Proposal game:references player:references url:string

# Guess
rails generate model Guess player:references proposal:references guessed_author:references
```

### Ajuster les migrations

```ruby
# db/migrate/xxx_create_teams.rb
class CreateTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.references :organizer, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end

# db/migrate/xxx_create_memberships.rb
class CreateMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.timestamps
    end
    add_index :memberships, [:user_id, :team_id], unique: true
  end
end

# db/migrate/xxx_create_games.rb
class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.references :team, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.datetime :started_at
      t.datetime :finished_at
      t.timestamps
    end
    add_index :games, :status
  end
end

# db/migrate/xxx_create_proposals.rb
class CreateProposals < ActiveRecord::Migration[8.0]
  def change
    create_table :proposals do |t|
      t.references :game, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: { to_table: :users }
      t.string :url, null: false
      t.timestamps
    end
    add_index :proposals, [:game_id, :url], unique: true
    add_index :proposals, [:game_id, :player_id], unique: true
  end
end

# db/migrate/xxx_create_guesses.rb
class CreateGuesses < ActiveRecord::Migration[8.0]
  def change
    create_table :guesses do |t|
      t.references :player, null: false, foreign_key: { to_table: :users }
      t.references :proposal, null: false, foreign_key: true
      t.references :guessed_author, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :guesses, [:player_id, :proposal_id], unique: true
  end
end
```

```bash
rails db:migrate
```

---

## Configuration des routes

```ruby
# config/routes.rb
Rails.application.routes.draw do
  devise_for :users
  
  resources :teams do
    resources :memberships, only: [:create, :destroy]
    resources :games, only: [:index, :new, :create]
  end
  
  resources :games, only: [:show] do
    member do
      patch :start_guessing
      patch :finish
    end
    
    resources :proposals, only: [:new, :create, :show]
    resources :guesses, only: [:new, :create]
    
    resource :results, only: [:show]
  end
  
  root "teams#index"
end
```

---

## Lancer l'application

```bash
# Démarrer le serveur (avec TailwindCSS watch)
bin/dev
```

Ouvrir <http://localhost:3000>

---

## Tests

```bash
# Tous les tests
rails test

# Tests système (UI)
rails test:system

# Un fichier spécifique
rails test test/models/game_test.rb
```

---

## Linting

```bash
# RuboCop
bin/rubocop

# Auto-fix
bin/rubocop -A
```

---

## Structure finale

```text
hitguessr/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   ├── teams_controller.rb
│   │   ├── memberships_controller.rb
│   │   ├── games_controller.rb
│   │   ├── proposals_controller.rb
│   │   ├── guesses_controller.rb
│   │   └── results_controller.rb
│   ├── models/
│   │   ├── user.rb
│   │   ├── team.rb
│   │   ├── membership.rb
│   │   ├── game.rb
│   │   ├── proposal.rb
│   │   └── guess.rb
│   └── views/
│       ├── teams/
│       ├── games/
│       ├── proposals/
│       ├── guesses/
│       └── results/
├── config/
│   ├── routes.rb
│   └── initializers/
│       └── devise.rb
├── db/
│   ├── migrate/
│   └── schema.rb
└── test/
    ├── models/
    ├── controllers/
    └── system/
```

---

## Prochaines étapes

1. Implémenter les modèles avec validations (voir [data-model.md](data-model.md))
2. Implémenter les contrôleurs avec authorization
3. Créer les vues avec TailwindCSS (voir [contracts/views.md](contracts/views.md))
4. Écrire les tests unitaires et système
5. Configurer CI (GitHub Actions)
