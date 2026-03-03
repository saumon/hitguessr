# Feature Specification: Classement général de l'équipe

**Feature Branch**: `004-team-leaderboard`  
**Created**: 2026-02-01  
**Status**: Shipped  
**Input**: User description: "Au niveau de l'écran de l'affichage de l'équipe, on doit avoir un classement général. Ce classement représente la somme pour chaque personne de tous les points obtenus dans toutes les parties au sein de l'équipe. Comme pour l'écran d'affichage des résultats d'une partie, le classement général au niveau de l'équipe doit lui aussi trier les membres par point décroissant et afficher des médailles en fonction du classement. Les points du classement général ne doivent pas être persistés. Ceux-ci sont uniquement la somme de ceux obtenus pour chaque personne, pour chaque partie de l'équipe."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Affichage du classement général (Priority: P1) 🎯 MVP

Un membre de l'équipe consulte la page de l'équipe et voit un classement général qui affiche tous les membres triés par score décroissant. Ce classement montre la somme des points obtenus par chaque membre dans toutes les parties terminées de l'équipe.

**Why this priority**: C'est la fonctionnalité principale demandée. Sans elle, la feature n'a pas de valeur. Elle permet aux joueurs de voir leur progression globale et de comparer leurs performances avec les autres membres de l'équipe.

**Independent Test**: Se connecter comme membre d'une équipe ayant des parties terminées → consulter la page de l'équipe → voir le classement général avec les scores cumulés

**Acceptance Scenarios**:

1. **Given** une équipe avec des parties terminées, **When** un membre accède à la page de l'équipe, **Then** il voit un classement général avec tous les joueurs ayant participé à au moins une partie
2. **Given** une équipe avec plusieurs parties terminées, **When** un membre consulte le classement, **Then** les scores affichés sont la somme des points de toutes les parties pour chaque joueur
3. **Given** un classement général, **When** il est affiché, **Then** les joueurs sont triés par score décroissant (du plus élevé au plus bas)

---

### User Story 2 - Affichage des médailles (Priority: P1)

Les trois premiers du classement général ont une médaille affichée à côté de leur nom, conformément à l'affichage de l'écran des résultats d'une partie (🥇 pour le 1er, 🥈 pour le 2ème, 🥉 pour le 3ème).

**Why this priority**: L'affichage des médailles fait partie intégrante de l'expérience utilisateur demandée et est essentiel pour la cohérence avec l'écran des résultats.

**Independent Test**: Consulter le classement général d'une équipe avec au moins 3 joueurs ayant participé → vérifier que les médailles sont affichées correctement

**Acceptance Scenarios**:

1. **Given** un classement avec au moins 3 joueurs, **When** le classement est affiché, **Then** le 1er a 🥇, le 2ème a 🥈, le 3ème a 🥉
2. **Given** un classement avec 2 joueurs seulement, **When** le classement est affiché, **Then** le 1er a 🥇, le 2ème a 🥈
3. **Given** deux joueurs à égalité en 1ère position, **When** le classement est affiché, **Then** les deux ont 🥇 (ex aequo)

---

### User Story 3 - Gestion des équipes sans parties (Priority: P2)

Lorsqu'une équipe n'a aucune partie terminée, le classement général affiche un message indiquant qu'aucun classement n'est disponible.

**Why this priority**: C'est un cas limite important pour l'expérience utilisateur mais ne bloque pas la feature principale.

**Independent Test**: Créer une équipe sans parties terminées → consulter la page de l'équipe → voir un message approprié à la place du classement

**Acceptance Scenarios**:

1. **Given** une équipe sans aucune partie, **When** un membre accède à la page de l'équipe, **Then** un message indique qu'aucun classement n'est disponible
2. **Given** une équipe avec uniquement des parties en cours (collecting ou guessing), **When** un membre consulte la page, **Then** le classement n'inclut pas ces parties non terminées

---

### Edge Cases

- Que se passe-t-il si un joueur n'a jamais participé à aucune partie terminée ? → Il n'apparaît pas dans le classement
- Comment gérer les ex aequo ? → Les joueurs à égalité partagent le même rang et la même médaille
- Un joueur qui rejoint l'équipe après des parties terminées ? → Il n'apparaît pas dans le classement (pas de score)
- Une partie sans aucune devinette (score 0 pour tous) ? → Les joueurs apparaissent avec 0 points

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT afficher un classement général sur la page de l'équipe
- **FR-002**: Le classement DOIT calculer la somme des points de chaque joueur sur toutes les parties terminées de l'équipe
- **FR-003**: Le classement DOIT trier les joueurs par score décroissant
- **FR-004**: Le système DOIT afficher des médailles (🥇🥈🥉) pour les 3 premiers
- **FR-005**: Les joueurs à égalité DOIVENT partager le même rang et la même médaille
- **FR-006**: Le système NE DOIT PAS persister les scores du classement général (calcul à la volée)
- **FR-007**: Seules les parties terminées (status: finished) DOIVENT être prises en compte dans le calcul
- **FR-008**: Le système DOIT afficher un message approprié si aucune partie terminée n'existe
- **FR-009**: Le classement DOIT n'inclure que les joueurs ayant participé à au moins une partie terminée

### Key Entities

- **Team**: L'équipe possédant le classement général. Relation existante avec Games.
- **Game**: Les parties terminées dont les scores sont agrégés. Méthode `calculate_scores` existante.
- **User (Player)**: Les joueurs dont les scores sont cumulés à travers les parties.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Le classement général est visible sur la page de l'équipe en moins de 1 seconde de chargement
- **SC-002**: Les scores affichés correspondent exactement à la somme des scores de toutes les parties terminées
- **SC-003**: L'ordre du classement est cohérent avec les scores (décroissant strict, ex aequo gérés)
- **SC-004**: L'affichage des médailles est identique à celui de l'écran des résultats d'une partie
- **SC-005**: 100% des membres de l'équipe peuvent consulter le classement général (pas de restriction d'accès)

## Assumptions

- Le calcul des scores par partie utilise la méthode `Game#calculate_scores` existante
- L'affichage des médailles suit le même pattern visuel que l'écran des résultats (`app/views/results/show.html.erb`)
- Le classement est calculé à chaque affichage de la page (pas de cache)
- Un joueur doit avoir fait au moins une devinette (guess) dans une partie terminée pour apparaître dans le classement (les scores sont basés sur les guesses, pas les proposals)
