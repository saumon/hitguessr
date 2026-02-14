# API Contract: Cancel Game

**Feature**: 003-cancel-active-game  
**Date**: 2026-02-01

## Endpoint

```text
DELETE /games/:id
```

## Description

Supprime définitivement une partie active et toutes ses données associées (proposals, guesses). Seul l'organisateur de l'équipe propriétaire peut effectuer cette action.

---

## Request

### Headers

| Header        | Value                          | Required |
|---------------|--------------------------------|----------|
| Accept        | text/html, application/json    | No       |
| Content-Type  | (none for DELETE)              | —        |
| Cookie        | session cookie (auth)          | Yes      |

### Path Parameters

| Parameter | Type    | Description          |
|-----------|---------|----------------------|
| id        | integer | ID of the game       |

### Body

None.

---

## Responses

### Success (HTML redirect)

**Status**: `303 See Other`  
**Location**: `/teams/:team_id/games`  
**Flash notice**: "Partie annulée avec succès."

### Success (JSON)

**Status**: `200 OK`

```json
{
  "success": true,
  "message": "Partie annulée avec succès."
}
```

### Error: Unauthorized (not organizer)

**Status**: `403 Forbidden`

HTML: Redirect to team page with flash alert "Seul l'organisateur peut effectuer cette action."

JSON:

```json
{
  "success": false,
  "error": "Seul l'organisateur peut effectuer cette action."
}
```

### Error: Not Found

**Status**: `404 Not Found`

HTML: Redirect to teams index with flash alert "Partie introuvable."

JSON:

```json
{
  "success": false,
  "error": "Partie introuvable."
}
```

### Error: Invalid State (game already finished)

**Status**: `422 Unprocessable Entity`

HTML: Redirect back with flash alert "Impossible d'annuler une partie terminée."

JSON:

```json
{
  "success": false,
  "error": "Impossible d'annuler une partie terminée."
}
```

---

## Authorization

- User must be authenticated (Devise session).
- User must be the `organizer` of the `team` that owns the game.

---

## Side Effects

- Game record deleted.
- All associated Proposal records deleted (cascade).
- All associated Guess records deleted (cascade).
- Redirects to team games index on success.

---

## Example cURL

```bash
curl -X DELETE "http://localhost:3000/games/42" \
  -H "Accept: application/json" \
  -b "_hitguessr_session=..."
```
