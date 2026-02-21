# API Contract: Game Creation (modified behavior)

**Feature**: 002-single-active-game  
**Date**: 2026-01-31

## Overview

Cette fonctionnalité ne crée pas de nouveaux endpoints API. Elle modifie le comportement de l'action `POST /teams/:team_id/games` existante en ajoutant une validation qui empêche la création si une partie active existe déjà.

## Modified Endpoint

### POST /teams/:team_id/games

Crée une nouvelle partie pour l'équipe spécifiée.

**Authorization**: Organisateur de l'équipe uniquement

#### Success Response (201 Created → Redirect)

**Condition**: Aucune partie active pour l'équipe

```text
HTTP/1.1 302 Found
Location: /games/:id
```

Flash notice: "Partie lancée ! Les joueurs peuvent maintenant soumettre leurs propositions."

#### Error Response (422 Unprocessable Entity)

**Condition**: Une partie active existe déjà pour l'équipe

```text
HTTP/1.1 422 Unprocessable Entity
Content-Type: text/html
```

Renders `games/new` template with error message displayed.

**Error Message**: "Une partie est déjà en cours pour cette équipe. Terminez-la avant d'en lancer une nouvelle."

## UI Contract

### Teams Show Page (`/teams/:id`)

#### Button State: Enabled

**Condition**: `@team.has_active_game? == false`

```html
<a href="/teams/:id/games/new" class="btn-neon btn-primary ...">
  🎧 Lancer une partie
</a>
```

#### Button State: Disabled

**Condition**: `@team.has_active_game? == true`

```html
<span class="group relative">
  <span class="btn-neon btn-primary ... opacity-50 cursor-not-allowed">
    🎧 Lancer une partie
  </span>
  <span class="tooltip group-hover:visible">
    Une partie est déjà en cours
  </span>
</span>
```

**Accessibility**: Le tooltip est également accessible via `aria-label` sur le bouton désactivé.

## Test Scenarios

| Scenario | Pre-condition | Action | Expected Result |
| -------- | ------------- | ------ | --------------- |
| Create OK | No active game | POST /teams/:id/games | 302 → /games/:new_id |
| Create blocked | Game in collecting | POST /teams/:id/games | 422, error message |
| Create blocked | Game in guessing | POST /teams/:id/games | 422, error message |
| Create OK | Only finished games | POST /teams/:id/games | 302 → /games/:new_id |
| Button enabled | No active game | GET /teams/:id | Button clickable |
| Button disabled | Active game exists | GET /teams/:id | Button grayed, tooltip |
