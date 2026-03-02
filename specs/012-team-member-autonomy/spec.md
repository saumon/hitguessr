# Feature Specification: Autonomie des membres d'équipe

**Feature Branch**: `012-team-member-autonomy`  
**Created**: 2026-03-01  
**Status**: Draft  
**Input**: User description: "Je veux que les membres de l'équipe aient plus d'autonomie au cas où l'organisateur n'est pas là. Tout membre de l'équipe doit pouvoir 'Lancer une partie', 'Passer aux devinetttes', 'Terminer la partie'. Seul l'organisateur garde le droit exclusif 'Annuler la partie', ainsi que la gestion des membres de l'équipe (Ajouter / Retirer un membre)."

## Clarifications

### Session 2026-03-01

- Q: Pour les actions non autorisées côté interface, faut-il les cacher, les désactiver, ou les laisser visibles puis bloquer seulement côté serveur ? → A: Les actions non autorisées sont cachées totalement pour le rôle courant.
- Q: En cas de tentative d'accès non autorisé via URL directe, quelle réponse UX doit être fournie ? → A: L'utilisateur est redirigé vers l'écran d'équipe/partie avec un message d'erreur clair.
- Q: Qui peut exécuter les actions de progression (lancer/passer aux devinettes/terminer) ? → A: Tous les membres de l'équipe, y compris l'organisateur.
- Q: En cas de transitions concurrentes, quel comportement adopter pour la seconde requête si l'état a déjà changé ? → A: La seconde requête est refusée avec un conflit explicite indiquant que l'état a déjà changé.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Continuer une partie sans organisateur (Priority: P1)

En tant que membre d'équipe, je peux lancer une partie, la faire avancer vers la phase de devinettes et la terminer même si l'organisateur est absent, afin que l'équipe ne soit pas bloquée.

**Why this priority**: C'est la valeur principale demandée: supprimer la dépendance opérationnelle à un seul rôle pendant le déroulement normal d'une partie.

**Independent Test**: Peut être testé en créant une équipe avec organisateur + membre, puis en vérifiant que le membre peut exécuter les 3 actions de progression de partie dans l'ordre et atteindre une partie terminée.

**Acceptance Scenarios**:

1. **Given** une équipe avec une partie en attente de démarrage et un utilisateur membre connecté, **When** le membre lance la partie, **Then** la partie passe à l'état démarré.
2. **Given** une partie démarrée et un utilisateur membre connecté, **When** le membre passe à la phase de devinettes, **Then** la partie passe à la phase de devinettes.
3. **Given** une partie en phase de devinettes et un utilisateur membre connecté, **When** le membre termine la partie, **Then** la partie passe à l'état terminée.

---

### User Story 2 - Protéger les actions réservées à l'organisateur (Priority: P1)

En tant qu'équipe, nous voulons que seules les actions critiques de gouvernance restent réservées à l'organisateur: annuler la partie et gérer les membres (ajouter/retirer).

**Why this priority**: Garantit que l'autonomie demandée n'élargit pas accidentellement les droits sensibles de contrôle d'équipe.

**Independent Test**: Peut être testé en tentant chaque action réservée avec un membre non organisateur et en vérifiant le refus, puis avec l'organisateur et en vérifiant l'autorisation.

**Acceptance Scenarios**:

1. **Given** une équipe avec une partie active et un utilisateur membre connecté, **When** le membre tente d'annuler la partie, **Then** l'action est refusée et l'état de la partie ne change pas.
2. **Given** une équipe et un utilisateur membre connecté, **When** le membre tente d'ajouter ou retirer un membre, **Then** l'action est refusée et la composition de l'équipe ne change pas.
3. **Given** une équipe et un organisateur connecté, **When** l'organisateur annule une partie ou modifie les membres, **Then** l'action est autorisée et appliquée.

---

### User Story 3 - Comprendre clairement ses permissions (Priority: P2)

En tant qu'utilisateur, je vois clairement quelles actions je peux exécuter selon mon rôle, afin d'éviter les erreurs et les tentatives inutiles.

**Why this priority**: Réduit la confusion et les frictions UX après l'évolution des permissions.

**Independent Test**: Peut être testé en comparant l'interface et les actions disponibles pour un membre et un organisateur sur le même état de partie.

**Acceptance Scenarios**:

1. **Given** un membre connecté sur l'écran d'une partie, **When** il consulte les actions disponibles, **Then** il voit les actions lancer/passer aux devinettes/terminer et ne voit pas annuler la partie ni gérer les membres.
2. **Given** un organisateur connecté sur le même écran, **When** il consulte les actions disponibles, **Then** il voit les actions de progression et les actions exclusives d'annulation et de gestion des membres.

### Edge Cases

- Un membre tente une action de progression sur une partie déjà terminée ou annulée: l'action est refusée avec un message explicite.
- Deux membres déclenchent la même transition quasi simultanément: une seule transition est appliquée, l'autre est refusée avec un conflit explicite indiquant que l'état a déjà changé.
- Un membre perd son statut (retiré de l'équipe) pendant qu'il a l'écran ouvert: toute action ultérieure est refusée.
- Un utilisateur hors équipe tente d'appeler une action de partie via URL directe: l'accès est refusé, l'utilisateur est redirigé vers l'écran d'équipe/partie et un message d'erreur explicite est affiché.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT autoriser tout membre de l'équipe, y compris l'organisateur, à lancer une partie uniquement depuis le contexte équipe sans partie active, avec création d'une partie en état `collecting`.
- **FR-002**: Le système DOIT autoriser tout membre de l'équipe, y compris l'organisateur, à faire passer une partie à la phase de devinettes uniquement lorsque la partie est en état `collecting`.
- **FR-003**: Le système DOIT autoriser tout membre de l'équipe, y compris l'organisateur, à terminer une partie uniquement lorsque la partie est en état `guessing`.
- **FR-004**: Le système DOIT réserver strictement à l'organisateur l'action d'annuler une partie.
- **FR-005**: Le système DOIT réserver strictement à l'organisateur les actions d'ajout et de retrait de membres de l'équipe.
- **FR-006**: Le système DOIT vérifier les permissions au moment de l'exécution de chaque action, y compris si l'utilisateur contourne l'interface.
- **FR-007**: Le système DOIT empêcher toute transition de phase invalide et conserver l'intégrité de l'état de partie.
- **FR-008**: Le système DOIT fournir un retour utilisateur clair en cas d'action refusée (permission insuffisante ou état incompatible).
- **FR-009**: Le système DOIT présenter des actions cohérentes avec le rôle de l'utilisateur afin de refléter les droits réellement applicables.
- **FR-010**: Le système DOIT masquer dans l'interface les actions non autorisées pour le rôle courant (elles ne doivent pas être affichées comme désactivées).
- **FR-011**: Le système DOIT, en cas d'accès non autorisé à une action via URL directe, rediriger l'utilisateur vers l'écran d'équipe/partie avec un message d'erreur clair.
- **FR-012**: Le système DOIT refuser explicitement une requête de transition concurrente devenue invalide après changement d'état, avec un message de conflit explicite indiquant que l'état a déjà changé.

### Transition Matrix

- **TM-001 (Lancer une partie)**: Autorisé uniquement depuis le contexte équipe sans partie active; crée une partie en état `collecting`.
- **TM-002 (Passer aux devinettes)**: Autorisé uniquement pour une partie en état `collecting`.
- **TM-003 (Terminer la partie)**: Autorisé uniquement pour une partie en état `guessing`.
- **TM-004 (Annuler la partie)**: Autorisé uniquement pour une partie en état `collecting` ou `guessing`, organisateur uniquement.

### Key Entities *(include if feature involves data)*

- **Team Member Role**: Relation entre un utilisateur et une équipe, avec un rôle (organisateur ou membre) qui détermine les autorisations d'action.
- **Game State**: État métier d'une partie (par exemple en attente, démarrée, phase de devinettes, terminée, annulée) utilisé pour valider les transitions.
- **Team Membership**: Appartenance active d'un utilisateur à l'équipe, prérequis pour exécuter toute action sur la partie de l'équipe.

### Assumptions & Dependencies

- Le modèle de rôles existant distingue déjà au minimum « organisateur » et « membre ».
- Les actions de progression de partie existent déjà; cette feature modifie le périmètre d'autorisation, pas la définition des phases.
- Les règles de transition d'état d'une partie restent inchangées.
- Les écrans de gestion d'équipe et de partie partagent les mêmes règles d'autorisation côté serveur.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Dans des tests d'acceptation, 100% des membres non organisateurs peuvent réaliser les actions lancer/passer aux devinettes/terminer sur des parties dans un état valide.
- **SC-002**: Dans des tests d'acceptation, 100% des tentatives de membres non organisateurs pour annuler une partie ou gérer les membres sont refusées.
- **SC-003**: Au moins 95% des utilisateurs testeurs identifient correctement, en moins de 10 secondes, quelles actions leur sont autorisées sur l'écran de partie.
- **SC-004**: 95% des actions autorisées de progression de partie aboutissent à un changement d'état visible pour l'utilisateur en moins de 2 secondes dans des conditions normales d'utilisation.
- **SC-005**: Aucun cas d'incohérence d'état (double transition concurrente appliquée) n'est observé sur un lot de 200 transitions de phase testées.
- **SC-006**: 100% des actions primaires de progression et de gouvernance restent opérables au clavier et avec un retour textuel lisible sur les écrans équipe/partie.
