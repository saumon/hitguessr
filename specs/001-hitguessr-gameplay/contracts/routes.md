# API Routes Contract: HitGuessr

**Date**: 2026-01-31  
**Branch**: `001-hitguessr-gameplay`

Ce document définit les routes RESTful Rails pour l'application HitGuessr.

---

## Authentication Routes (Devise)

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | /users/sign_up | devise/registrations#new | Formulaire inscription |
| POST | /users | devise/registrations#create | Créer compte |
| GET | /users/sign_in | devise/sessions#new | Formulaire connexion |
| POST | /users/sign_in | devise/sessions#create | Connexion |
| DELETE | /users/sign_out | devise/sessions#destroy | Déconnexion |
| GET | /users/password/new | devise/passwords#new | Demande reset password |
| POST | /users/password | devise/passwords#create | Envoyer email reset |
| GET | /users/password/edit | devise/passwords#edit | Formulaire nouveau password |
| PATCH | /users/password | devise/passwords#update | Changer password |

---

## Teams Routes

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | /teams | teams#index | Liste mes équipes |
| GET | /teams/new | teams#new | Formulaire création équipe |
| POST | /teams | teams#create | Créer équipe |
| GET | /teams/:id | teams#show | Détail équipe + membres |
| GET | /teams/:id/edit | teams#edit | Formulaire édition (organizer) |
| PATCH | /teams/:id | teams#update | Modifier équipe (organizer) |
| DELETE | /teams/:id | teams#destroy | Supprimer équipe (organizer) |

### Nested: Memberships

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| POST | /teams/:team_id/memberships | memberships#create | Ajouter membre (organizer) |
| DELETE | /teams/:team_id/memberships/:id | memberships#destroy | Retirer membre (organizer) |

---

## Games Routes

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | /teams/:team_id/games | games#index | Liste parties de l'équipe |
| GET | /teams/:team_id/games/new | games#new | Formulaire nouvelle partie |
| POST | /teams/:team_id/games | games#create | Lancer partie (organizer) |
| GET | /games/:id | games#show | Détail partie (phase-aware) |
| PATCH | /games/:id/start_guessing | games#start_guessing | Passer en phase devinettes (organizer) |
| PATCH | /games/:id/finish | games#finish | Terminer partie (organizer) |

---

## Proposals Routes

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | /games/:game_id/proposals/new | proposals#new | Formulaire proposition |
| POST | /games/:game_id/proposals | proposals#create | Soumettre proposition |
| GET | /games/:game_id/proposals/:id | proposals#show | Voir ma proposition (player only) |

**Note**: Pas de `index` public pendant phase collecte (propositions invisibles).

---

## Guesses Routes

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | /games/:game_id/guesses/new | guesses#new | Formulaire devinettes |
| POST | /games/:game_id/guesses | guesses#create | Soumettre toutes devinettes |

**Note**: Soumission en batch uniquement (toutes les devinettes d'un coup).

---

## Results Routes

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | /games/:id/results | results#show | Résultats et classement |

---

## Routes File (config/routes.rb)

```ruby
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

## Authorization Rules

| Resource | Action | Authorized |
|----------|--------|------------|
| Team | create | Any authenticated user |
| Team | update/destroy | Organizer only |
| Membership | create/destroy | Organizer only |
| Game | create | Organizer only |
| Game | start_guessing/finish | Organizer only |
| Proposal | create | Team member, during collecting phase |
| Proposal | show (own) | Owner only |
| Guesses | create | Team member, during guessing phase |
| Results | show | Team member, after finished |

---

## Response Formats

Toutes les routes retournent du HTML (Rails views avec TailwindCSS).
Pas d'API JSON pour cette version (MVP monolithique).

### Success Responses

| Action | Response |
|--------|----------|
| Create | Redirect to resource + flash success |
| Update | Redirect to resource + flash success |
| Destroy | Redirect to index + flash success |

### Error Responses

| Scenario | Response |
|----------|----------|
| Validation errors | Re-render form with errors |
| Unauthorized | Redirect to sign_in (Devise) |
| Forbidden | Redirect back + flash alert |
| Not found | Rails default 404 |
| Invalid transition | Redirect back + flash alert |
