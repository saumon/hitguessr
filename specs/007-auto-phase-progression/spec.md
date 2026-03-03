# Feature Specification: Progression Automatique des Phases de Jeu

**Feature Branch**: `007-auto-phase-progression`  
**Created**: 14 février 2026  
**Status**: Shipped  
**Input**: User description: "Si 100% des joueurs inscrits dans l'équipe ont soumis leurs propositions, il n'est pas nécessaire d'attendre que l'organisateur de la partie passe à l'étape suivante (phase de devinette). Idem, lors de la phase de devinette, si 100% des joueurs ont soumis leur réponse, alors la partie peut se terminer automatiquement."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Avancement automatique vers la phase de devinettes (Priority: P1)

En tant que joueur d'une équipe, lorsque je soumets ma proposition et que tous les autres membres de l'équipe ont déjà soumis la leur, la partie passe automatiquement en phase de devinettes sans intervention de l'organisateur. Cela permet à l'équipe de continuer à jouer plus rapidement sans attendre que l'organisateur soit disponible.

**Why this priority**: Cette fonctionnalité représente la valeur principale de la feature car elle élimine le blocage le plus fréquent - l'attente de l'organisateur pour démarrer les devinettes. Elle améliore significativement l'expérience utilisateur en permettant une progression fluide du jeu.

**Independent Test**: Peut être testé complètement en créant une équipe de 3 joueurs, en soumettant 2 propositions, puis en observant que la soumission de la 3ème proposition déclenche automatiquement le passage en phase de devinettes.

**Acceptance Scenarios**:

1. **Given** une partie en phase de collecte avec une équipe de 4 membres et 3 propositions déjà soumises, **When** le 4ème membre soumet sa proposition, **Then** la partie passe automatiquement en phase de devinettes et tous les joueurs voient l'interface de devinettes.

2. **Given** une partie en phase de collecte avec une équipe de 3 membres et 1 proposition soumise, **When** le 2ème membre soumet sa proposition, **Then** la partie reste en phase de collecte car il reste un membre sans proposition.

3. **Given** une partie en phase de collecte avec une équipe de 2 membres, **When** le 2ème membre soumet sa proposition, **Then** la partie passe automatiquement en phase de devinettes (le minimum de 2 propositions étant atteint).

---

### User Story 2 - Terminaison automatique de la partie (Priority: P1)

En tant que joueur d'une équipe, lorsque je soumets ma dernière devinette et que tous les autres joueurs ont également complété toutes leurs devinettes, la partie se termine automatiquement et les résultats s'affichent. Cela permet une conclusion naturelle du jeu sans intervention manuelle.

**Why this priority**: Cette fonctionnalité est également critique car elle complète le cycle automatique du jeu. Sans elle, les joueurs devraient attendre l'organisateur même après avoir tous terminé leurs devinettes, ce qui créerait une frustration.

**Independent Test**: Peut être testé en créant une partie en phase de devinettes avec 3 propositions, en soumettant toutes les devinettes sauf une, puis en observant que la dernière devinette déclenche la fin de partie et l'affichage des résultats.

**Acceptance Scenarios**:

1. **Given** une partie en phase de devinettes avec 3 propositions (donc 3 joueurs, chacun devant deviner 2 propositions = 6 devinettes au total) et 5 devinettes déjà soumises, **When** le dernier joueur soumet sa dernière devinette, **Then** la partie se termine automatiquement et les résultats sont affichés.

2. **Given** une partie en phase de devinettes avec 3 propositions et 4 devinettes soumises, **When** un joueur soumet une devinette (5ème), **Then** la partie reste en phase de devinettes car il reste des devinettes à soumettre.

---

### User Story 3 - Notification de la progression automatique (Priority: P2)

En tant que joueur, lorsque la partie progresse automatiquement (vers la phase de devinettes ou vers la fin), je suis informé de ce changement d'état de manière claire. Cela me permet de comprendre ce qui s'est passé et de savoir quoi faire ensuite.

**Why this priority**: L'information utilisateur est importante pour la compréhension du flux, mais le comportement automatique fonctionne même sans notification explicite (la page se met à jour). C'est un "nice to have" pour l'expérience.

**Independent Test**: Peut être testé en observant qu'un message ou indicateur visuel apparaît lorsque la progression automatique se déclenche.

**Acceptance Scenarios**:

1. **Given** une partie qui vient de progresser automatiquement vers la phase de devinettes, **When** je consulte l'interface de jeu, **Then** je vois une indication que la phase de devinettes a commencé.

2. **Given** une partie qui vient de se terminer automatiquement, **When** je consulte l'interface, **Then** je vois l'écran des résultats avec les scores.

---

### Edge Cases

- Que se passe-t-il si un nouveau membre rejoint l'équipe pendant la phase de collecte ? → Le nouveau membre doit également soumettre sa proposition pour que la progression automatique se déclenche.
- Que se passe-t-il si un membre quitte l'équipe pendant une partie active ? → La progression automatique recalcule le nombre de membres actuels pour déterminer si 100% ont soumis (le membre parti n'est plus comptabilisé).
- Que se passe-t-il si l'organisateur déclenche manuellement la phase suivante avant que tous aient soumis ? → La progression manuelle reste disponible et prioritaire. L'organisateur peut toujours avancer la partie avec au moins 2 propositions.
- Que se passe-t-il avec 0 ou 1 membre dans l'équipe ? → Impossible de créer une partie valide (minimum 2 propositions requis), donc ce cas ne devrait pas se présenter.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT détecter automatiquement quand tous les membres de l'équipe ont soumis leur proposition pendant la phase de collecte.
- **FR-002**: Le système DOIT faire progresser automatiquement la partie vers la phase de devinettes lorsque 100% des membres de l'équipe ont soumis leur proposition.
- **FR-003**: Le système DOIT calculer le nombre total de devinettes attendues selon la formule : N joueurs × (N-1) propositions à deviner par joueur.
- **FR-004**: Le système DOIT détecter automatiquement quand toutes les devinettes attendues ont été soumises pendant la phase de devinettes.
- **FR-005**: Le système DOIT terminer automatiquement la partie lorsque 100% des devinettes attendues ont été soumises.
- **FR-006**: Le système DOIT continuer à permettre à l'organisateur de déclencher manuellement les transitions de phase (comportement existant préservé).
- **FR-007**: Le système DOIT prendre en compte les changements de composition de l'équipe (membres ajoutés ou supprimés) dans le calcul du seuil de 100%.
- **FR-008**: Le système DOIT respecter la contrainte existante de minimum 2 propositions pour démarrer la phase de devinettes.

### Key Entities

- **Game**: Représente une partie de jeu avec son état (collecting, guessing, finished). La transition d'état peut maintenant être déclenchée automatiquement.
- **Proposal**: Représente une proposition de chanson par un joueur. Le nombre de propositions par rapport au nombre de membres détermine la progression automatique.
- **Guess**: Représente une devinette d'un joueur sur l'auteur d'une proposition. Le nombre total de devinettes par rapport au nombre attendu détermine la terminaison automatique.
- **Membership**: Représente l'appartenance d'un utilisateur à une équipe. Utilisé pour calculer le nombre total de membres de l'équipe.

## Clarifications

### Session 2026-02-14

- Q: Quelle stratégie de gestion de concurrence appliquer pour les soumissions simultanées ? → A: Verrouillage synchrone (row lock sur Game lors de la vérification + transition)

## Assumptions

- Un membre de l'équipe est défini par son appartenance active via la table des memberships au moment de l'évaluation.
- L'organisateur reste maître du jeu et peut toujours forcer les transitions manuellement (avec les conditions minimales existantes : au moins 2 propositions pour démarrer les devinettes).
- La progression automatique n'a pas d'impact sur le calcul des scores ou le classement final.
- En cas de progression simultanée (deux joueurs soumettent en même temps), le système utilise un verrouillage de ligne (row lock) sur l'entité Game pour garantir qu'une seule transition s'exécute - les autres tentatives concurrentes attendent le verrou puis constatent que la transition a déjà eu lieu.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Lorsque 100% des membres de l'équipe ont soumis leur proposition, la partie passe en phase de devinettes en moins de 5 secondes.
- **SC-002**: Lorsque 100% des devinettes attendues sont soumises, la partie se termine et affiche les résultats en moins de 5 secondes.
- **SC-003**: Le passage automatique vers la phase de devinettes réussit dans 100% des cas où tous les membres ont soumis.
- **SC-004**: La terminaison automatique de la partie réussit dans 100% des cas où toutes les devinettes sont soumises.
- **SC-005**: Les joueurs n'ont plus besoin d'attendre l'organisateur pour progresser quand tout le monde a participé.
- **SC-006**: Le comportement manuel existant (organisateur déclenchant les phases) reste fonctionnel et disponible comme alternative.
