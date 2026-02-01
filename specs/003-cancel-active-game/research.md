# Research: Annulation d'une partie active

**Feature**: 003-cancel-active-game  
**Date**: 2026-02-01

## Summary

Ce document résume la recherche effectuée pour lever les ambiguïtés de la spécification avant l'implémentation.

---

## 1. Stratégie de suppression (hard delete vs soft-delete)

**Decision**: Hard delete  
**Rationale**: La demande produit stipule explicitement « définitivement détruite de la base de données ». Un hard delete garantit la conformité à cette exigence, évite la complexité d'un champ `deleted_at` et les risques de fuite de données.  
**Alternatives considered**:

- Soft-delete avec restore : rejeté car complexité accrue et non demandé.
- Hard delete + audit log séparé : non nécessaire pour cette fonctionnalité mais pourrait être ajouté ultérieurement si besoin d'audit.

---

## 2. Cascade de suppression et intégrité des données

**Decision**: Utiliser `dependent: :destroy` sur les associations `Game → Proposals → Guesses`. La suppression d'une `Game` entraîne automatiquement la suppression des `Proposals` associées et, par cascade, des `Guesses`.  
**Rationale**: Rails Active Record garantit l'exécution des callbacks et le respect de l'ordre de suppression. Le schéma actuel utilise déjà `dependent: :destroy` sur `Team → Games` ; on applique le même pattern.  
**Alternatives considered**:

- `DELETE CASCADE` au niveau SQL : plus rapide pour gros volumes mais contourne les callbacks Rails (utiles pour logging/validations). Rejeté pour cohérence avec le reste du code.
- Suppression manuelle dans une transaction : redondant si `dependent: :destroy` est déjà défini.

---

## 3. Atomicité et gestion des erreurs

**Decision**: Encapsuler la suppression dans une transaction explicite (`ActiveRecord::Base.transaction { game.destroy! }`). Toute exception (contrainte FK, erreur de callback) déclenche un rollback et renvoie un message d'erreur.  
**Rationale**: Garantit la cohérence des données même en cas de concurrence ou d'erreur partielle.  
**Alternatives considered**:

- Pas de transaction explicite (Rails wrap `destroy` automatiquement) : acceptable mais moins explicite ; on préfère la clarté.

---

## 4. Autorisation

**Decision**: Réutiliser le helper existant `authorize_organizer_for_game!` du `GamesController`. Ce helper vérifie que `current_user == game.team.organizer`.  
**Rationale**: Pattern déjà en place pour `start_guessing` et `finish` ; assure cohérence.  
**Alternatives considered**:

- Gem d'autorisation (Pundit, CanCanCan) : hors scope car non utilisée dans le projet actuel.

---

## 5. Confirmation côté client (UX)

**Decision**: Utiliser une modale Turbo (ou Stimulus dialog) qui affiche un message explicite et requiert une action utilisateur (bouton « Confirmer »). Le bouton poste une requête `DELETE /games/:id`.  
**Rationale**: Turbo est déjà présent dans le projet ; pas de dépendance supplémentaire.  
**Alternatives considered**:

- `data-turbo-confirm` natif : solution minimaliste ; acceptable mais moins contrôlable visuellement.
- Page interstitielle séparée : trop lourd pour une simple confirmation.

---

## 6. Redirection et feedback après suppression

**Decision**: Après suppression réussie, rediriger vers `team_games_path(@team)` avec un flash `notice` ("Partie annulée avec succès."). En cas d'erreur, rester sur la page courante avec un flash `alert`.  
**Rationale**: Cohérent avec le pattern existant (redirect après `create`, `start_guessing`, `finish`).

---

## 7. Gestion de la partie déjà terminée

**Decision**: Permettre l'annulation uniquement si `game.status != :finished`. Si la partie est terminée, renvoyer une erreur 422 avec message explicite.  
**Rationale**: Une partie terminée a des résultats potentiellement consultés ; la suppression pourrait surprendre les utilisateurs. (Note : le produit pourrait décider d'autoriser ; à confirmer si besoin.)  
**Alternatives considered**:

- Bloquer la suppression des parties finies au niveau UI seulement : insuffisant car contournable par requête directe.

---

## Open Questions (resolved)

| Question | Resolution |
| -------- | --------- |
| Hard delete vs soft-delete? | Hard delete (voir §1) |
| Cascade automatique ou manuelle? | `dependent: :destroy` (voir §2) |
| Transaction explicite? | Oui (voir §3) |
| Mécanisme d'autorisation? | Helper existant (voir §4) |
| Confirmation UI? | Modale Turbo / Stimulus (voir §5) |
| Peut-on supprimer une partie terminée? | Non, statut doit être `collecting` ou `guessing` (voir §7) |

---

## Open Notes

- **Async jobs**: No background jobs currently exist for game lifecycle (no score calculation jobs, no notification jobs). If added in the future, ensure they check for game existence before creating records to avoid orphans after cancellation.

## References

- Rails Guides: Active Record Associations – `dependent: :destroy`
- Turbo Handbook: Confirmation dialogs
- Existing codebase: `GamesController#authorize_organizer_for_game!`
