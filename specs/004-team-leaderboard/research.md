# Research: Classement général de l'équipe

**Feature**: 004-team-leaderboard  
**Date**: 2026-02-01

## Summary

Ce document résume la recherche effectuée pour l'implémentation du classement général de l'équipe.

---

## 1. Stratégie de calcul des scores cumulés

**Decision**: Agréger les scores en itérant sur `team.games.finished` et en accumulant les résultats de `Game#calculate_scores` par joueur.  
**Rationale**: La méthode `calculate_scores` existe déjà et fournit les scores par partie. L'agrégation est simple et ne nécessite pas de persistance.  
**Alternatives considered**:

- Persistance des scores cumulés en base : Rejeté car explicitement interdit par FR-006 et ajoute complexité de synchronisation.
- Calcul SQL direct avec agrégation : Plus performant pour gros volumes mais moins lisible et duplique la logique de scoring.

---

## 2. Gestion des ex aequo

**Decision**: Réutiliser le pattern de la méthode `Game#ranking` qui assigne le même rang aux joueurs à égalité.  
**Rationale**: Cohérence avec l'écran des résultats existant. L'algorithme parcourt les scores triés et attribue le même rang si le score est identique au précédent.  
**Alternatives considered**:

- Départage par nombre de parties jouées : Non demandé dans la spec.
- Départage alphabétique : Arbitraire et non mentionné.

---

## 3. Emplacement du classement dans la page

**Decision**: Ajouter une nouvelle section "Classement général" entre la section "Membres" et la section "Parties récentes".  
**Rationale**: Position logique - après les infos de l'équipe, avant l'historique des parties. Visibilité immédiate.  
**Alternatives considered**:

- Section séparée en haut : Trop proéminent, pourrait éclipser les actions principales.
- Section en bas : Moins visible, l'utilisateur doit scroller.

---

## 4. Performance

**Decision**: Calculer le classement à chaque chargement de page (pas de cache).  
**Rationale**:

- Taille typique : 2-20 membres, 0-50 parties ⇒ calcul rapide (< 100ms)
- Simplicité : pas de gestion d'invalidation de cache
- FR-006 interdit la persistance
**Alternatives considered**:

- Cache avec invalidation sur fin de partie : Complexité ajoutée non justifiée pour la taille actuelle.

---

## 5. Réutilisation du pattern visuel

**Decision**: Copier le markup du classement de `results/show.html.erb` pour la section leaderboard.  
**Rationale**: Cohérence UX (SC-004). Les utilisateurs reconnaîtront le même format de médailles et de classement.  
**Alternatives considered**:

- Partial partagé : Possible mais les contextes sont légèrement différents (partie vs équipe). Refactoring futur si besoin.

---

## 6. Joueurs sans participation

**Decision**: Ne pas afficher les membres de l'équipe qui n'ont participé à aucune partie terminée.  
**Rationale**: Conforme à FR-009. Un joueur sans score (0 parties) n'a pas de rang significatif.  
**Alternatives considered**:

- Afficher tous les membres avec score 0 : Pollue le classement avec des entrées non pertinentes.

---

## Open Questions (resolved)

| Question | Resolution |
| -------- | --------- |
| Où placer le classement dans la page ? | Entre "Membres" et "Parties récentes" (voir §3) |
| Faut-il cacher les résultats ? | Non, calcul à la volée acceptable (voir §4) |
| Pattern pour ex aequo ? | Même rang + même médaille (voir §2) |

---

## References

- Méthode existante : `Game#calculate_scores` et `Game#ranking`
- Pattern visuel : `app/views/results/show.html.erb`
- Constitution : Section IV (Performance Budgets) - respecté avec < 1s
