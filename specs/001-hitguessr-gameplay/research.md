# Research: HitGuessr - Décisions Techniques

**Date**: 2026-01-31  
**Context**: Choix techniques pour l'implémentation Rails 8.1.2 de HitGuessr

---

## 1. Rails 8.1.2 avec SQLite

### Decision
Utiliser SQLite par défaut avec la configuration Rails 8 standard.

### Rationale
- Rails 8 est optimisé pour SQLite en production ("local-first")
- Configuration par défaut stocke dans `storage/` (ex: `storage/development.sqlite3`)
- Rails 8.1 active `sqlite3_adapter_strict_strings_by_default: true` par défaut
- Aucune infrastructure serveur requise

### Alternatives considered
| Alternative | Rejected because |
|-------------|------------------|
| PostgreSQL | Surcharge pour un projet local-first simple |
| MySQL | Complexité inutile pour ce cas d'usage |

---

## 2. Devise avec Rails 8

### Decision
Utiliser Devise 5.x avec configuration Hotwire/Turbo intégrée.

### Rationale
- Devise 5 supporte nativement Hotwire/Turbo
- Modules nécessaires : `database_authenticatable`, `registerable`, `recoverable`, `rememberable`, `validatable`
- Configuration minimale, sécurité éprouvée

### Installation
```bash
bundle add devise
rails generate devise:install
rails generate devise User
rails db:migrate
```

### Configuration Turbo (Rails 8)
```ruby
# config/initializers/devise.rb
Devise.setup do |config|
  config.responder.error_status = :unprocessable_content  # Rack 3.1+
  config.responder.redirect_status = :see_other
end
```

### Alternatives considered
| Alternative | Rejected because |
|-------------|------------------|
| Authentication from scratch | Temps de développement, risques sécurité |
| Clearance | Moins de fonctionnalités, communauté plus petite |
| Rodauth | Courbe d'apprentissage plus longue |

---

## 3. TailwindCSS v4.1 avec Rails 8

### Decision
Utiliser `tailwindcss-rails` gem (v4.x) - sans Node.js.

### Rationale
- Zéro dépendance Node.js (exécutable Tailwind natif)
- Intégration parfaite avec l'asset pipeline Rails
- Plugin Puma inclus pour watch mode automatique
- Rails 8 supporte `--css tailwind` à la création

### Installation
```bash
# Nouvelle app
rails new hitguessr --css tailwind

# App existante
bundle add tailwindcss-rails
rails tailwindcss:install
```

### Structure fichiers (v4)
- Input: `app/assets/tailwind/application.css`
- Output: `app/assets/builds/tailwind.css`

### Alternatives considered
| Alternative | Rejected because |
|-------------|------------------|
| `cssbundling-rails` | Nécessite Node.js/Yarn |
| PostCSS standalone | Configuration manuelle |

---

## 4. Pattern machine à états pour phases de jeu

### Decision
Utiliser un enum Rails simple avec méthodes de transition custom.

### Rationale
- 3 phases linéaires (collecting → guessing → finished) = pas de gem externe
- Enum Rails natif suffit
- Transitions validables avec méthodes simples
- Moins de dépendances = moins de maintenance

### Pattern recommandé
```ruby
class Game < ApplicationRecord
  enum :status, { collecting: 0, guessing: 1, finished: 2 }
  
  def start_guessing!
    raise InvalidTransition unless collecting?
    update!(status: :guessing, guessing_started_at: Time.current)
  end
  
  def finish!
    raise InvalidTransition unless guessing?
    update!(status: :finished, finished_at: Time.current)
  end
  
  class InvalidTransition < StandardError; end
end
```

### Alternatives considered
| Alternative | Rejected because |
|-------------|------------------|
| AASM gem | Surcharge pour 3 états linéaires simples |
| StateMachines gem | Complexité non justifiée |

---

## 5. Validation liens dupliqués

### Decision
Validation de scope ActiveRecord avec normalisation d'URL.

### Rationale
- Validation native Rails, performante
- Scope au niveau du jeu (pas globalement)
- Normalisation évite faux négatifs (trailing slash, http vs https)

### Pattern recommandé
```ruby
class Proposal < ApplicationRecord
  belongs_to :game
  belongs_to :player
  
  before_validation :normalize_url
  
  validates :url, presence: true,
                  format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) },
                  uniqueness: { 
                    scope: :game_id, 
                    message: "Ce lien a déjà été proposé dans cette partie",
                    case_sensitive: false 
                  }
  
  private
  
  def normalize_url
    return if url.blank?
    uri = URI.parse(url.strip.downcase)
    uri.path = uri.path.chomp('/')
    uri.fragment = nil
    self.url = uri.to_s
  rescue URI::InvalidURIError
    # Will fail format validation
  end
end
```

### Index DB requis
```ruby
add_index :proposals, [:game_id, :url], unique: true
```

### Alternatives considered
| Alternative | Rejected because |
|-------------|------------------|
| Gem validation URL | Dépendance pour cas simple |
| Validation DB uniquement | Pas de messages erreur utilisateur |

---

## Résumé des décisions

| Domaine | Décision | Complexité |
|---------|----------|------------|
| Base de données | SQLite (défaut Rails 8) | Simple |
| Authentification | Devise 5.x | Modérée |
| CSS Framework | `tailwindcss-rails` v4.x | Simple |
| Machine à états | Enum Rails + méthodes custom | Simple |
| Validation URL | Scope uniqueness + normalisation | Simple |
