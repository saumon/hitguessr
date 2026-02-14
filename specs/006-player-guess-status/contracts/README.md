# API Contracts: Tableau de statut des joueurs en phase de devinettes

**Feature**: 006-player-guess-status
**Date**: 2026-02-14

## Status

**N/A** - Cette fonctionnalité ne nécessite aucun nouveau endpoint API.

## Rationale

Cette feature est une modification purement de la couche présentation (view layer):

- Modification du partial `_guessing.html.erb` pour ajouter le tableau de statut
- Passage de variables supplémentaires depuis le controller
- Aucune nouvelle route, aucun nouveau endpoint

Les pages existantes sont servies via le controller `GamesController#show` sans modification de l'interface HTTP.
