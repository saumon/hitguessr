# Feature Specification: Tableau de statut des joueurs en phase de devinettes

**Feature Branch**: `006-player-guess-status`  
**Created**: 2026-02-14  
**Status**: Draft  
**Input**: User description: "Lors de la phase devinette, ajouter un tableau de statut des joueurs sélectionnés avec leur statut de réponse (en attente, devinette soumise)"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Consulter le statut des joueurs en phase de devinettes (Priority: P1)

En tant que membre de l'équipe, lors de la phase de devinettes, je veux voir la liste des joueurs sélectionnés pour cette partie ainsi que leur statut de réponse (en attente / devinette soumise) afin de savoir qui n'a pas encore répondu et pouvoir organiser des relances si nécessaire.

**Why this priority**: Cette fonctionnalité répond directement au besoin métier principal - la visibilité sur l'avancement des devinettes pour faciliter l'organisation et les relances.

**Independent Test**: Testable en accédant à la page d'une partie en phase de devinettes et en vérifiant que le tableau de statut affiche tous les joueurs sélectionnés avec leur statut correct.

**Acceptance Scenarios**:

1. **Given** une partie en phase de devinettes avec 5 joueurs sélectionnés, **When** un membre de l'équipe consulte la page de la partie, **Then** il voit un tableau listant les 5 joueurs avec leur statut de réponse.
2. **Given** une partie en phase de devinettes où 3 joueurs ont soumis leurs devinettes et 2 sont en attente, **When** un membre consulte le tableau de statut, **Then** les 3 joueurs ayant répondu affichent "Devinette soumise" et les 2 autres affichent "En attente".
3. **Given** un joueur qui vient de soumettre ses devinettes, **When** la page de partie est rafraîchie, **Then** son statut passe de "En attente" à "Devinette soumise".

---

### User Story 2 - Cohérence visuelle avec la phase de collecte (Priority: P2)

En tant que membre de l'équipe, je veux que le tableau de statut en phase de devinettes soit visuellement cohérent avec celui de la phase de collecte des propositions, afin de maintenir une expérience utilisateur homogène.

**Why this priority**: La cohérence visuelle améliore l'utilisabilité et réduit la charge cognitive des utilisateurs.

**Independent Test**: Testable en comparant visuellement le tableau de statut de la phase de devinettes avec celui de la phase de collecte.

**Acceptance Scenarios**:

1. **Given** une partie en phase de devinettes, **When** le tableau de statut est affiché, **Then** il utilise le même format de présentation que celui de la phase de collecte (disposition, icônes, couleurs).
2. **Given** une partie en phase de devinettes sur mobile, **When** le tableau de statut est affiché, **Then** il s'adapte correctement à l'écran de la même manière que le tableau de la phase de collecte.

---

### Edge Cases

- Si un joueur n'a pas soumis de proposition (et est donc exclu du pool de devinettes), il n'apparaît pas dans le tableau de statut de la phase de devinettes.
- Si tous les joueurs ont soumis leurs devinettes, le tableau affiche 100% de "Devinette soumise".
- Si un seul joueur est dans le pool (cas limite), le tableau affiche un seul joueur avec son statut.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT afficher un tableau de statut des joueurs sur la page de partie en phase de devinettes.
- **FR-002**: Le tableau DOIT lister uniquement les joueurs ayant soumis une proposition (ceux faisant partie du pool de devinettes).
- **FR-003**: Pour chaque joueur, le tableau DOIT afficher son nom et son statut de réponse.
- **FR-004**: Le statut DOIT être "En attente" si le joueur n'a pas encore soumis toutes ses devinettes.
- **FR-005**: Le statut DOIT être "Devinette soumise" si le joueur a soumis toutes ses devinettes pour cette partie.
- **FR-006**: Le tableau DOIT être visible par tous les membres de l'équipe, pas seulement l'organisateur.
- **FR-007**: Le tableau DOIT se mettre à jour lors du rafraîchissement de la page pour refléter les changements de statut.

### Key Entities

- **Joueur sélectionné**: Membre de l'équipe ayant soumis une proposition et faisant partie du pool de devinettes pour cette partie.
- **Statut de réponse**: État indiquant si un joueur a soumis ou non ses devinettes pour la partie en cours.

### Assumptions

- Un joueur est considéré comme ayant soumis ses devinettes lorsqu'il a associé toutes les propositions (sauf la sienne) à un membre de l'équipe.
- Le tableau reprend la même structure visuelle que celui existant en phase de collecte des propositions.
- Les données de statut sont calculées à partir des devinettes existantes en base de données.

### Scope

**In Scope**:

- Affichage du tableau de statut des joueurs en phase de devinettes.
- Indicateurs visuels de statut (icônes, couleurs) cohérents avec la phase de collecte.
- Support responsive (mobile et desktop).

**Out of Scope**:

- Notifications push ou relances automatiques.
- Mise à jour en temps réel sans rafraîchissement de la page.
- Actions directes depuis le tableau (envoi d'email, etc.).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Le tableau de statut est visible immédiatement lors de l'accès à la page de partie en phase de devinettes, sans action supplémentaire de l'utilisateur.
- **SC-002**: Le statut affiché pour chaque joueur correspond à la réalité (vérifiable en comparant avec les données en base).
- **SC-003**: Le tableau est lisible et fonctionnel sur écrans mobiles (largeur minimum 320px) comme sur desktop.
- **SC-004**: La cohérence visuelle entre les tableaux de statut des deux phases (collecte et devinettes) est vérifiable lors d'une revue UX.
