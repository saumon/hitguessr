# Feature Specification: Annulation d'une partie active

**Feature Branch**: `003-cancel-active-game`  
**Created**: 2026-02-01  
**Status**: Shipped  
**Input**: User description: "Une partie en cours doit pouvoir être annulée par l'oranisateur (opération d'admisitration). Seul l'organisateur doit pouvoir annuler une partie dont il est le propriétaire. Un message de confirmation doit être affiché à l'organisateur avant l'annulation de la partie. Lorsque l'annulation de la partie est validée par l'organisateur, celle-ci est définitivement détruite de la base de données."

## Clarifications

### Session 2026-02-01

- Q: Do we perform a hard delete or soft-delete when an organizer confirms cancellation? → A: Suppression définitive (hard delete).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Annulation par l'organisateur (Priority: P1)

En tant qu'**organisateur propriétaire** d'une partie active, je veux pouvoir annuler définitivement cette partie afin que le jeu et ses données associées soient supprimés.

**Why this priority**: C'est l'opération demandée explicitement par le produit et protège la volonté du propriétaire de supprimer sa partie.

**Independent Test**: Se connecter en tant qu'organisateur propriétaire, ouvrir la page de la partie active et exécuter l'action "Annuler la partie" ; vérifier que la partie et ses données associées n'existent plus.

**Acceptance Scenarios**:

1. **Given** l'organisateur est connecté et propriétaire d'une partie active, **When** il clique sur "Annuler la partie", **Then** un message de confirmation explicite s'affiche demandant la confirmation de l'annulation.
2. **Given** la boîte de confirmation est affichée, **When** l'organisateur confirme, **Then** la partie et ses enregistrements associés (proposals, guesses) sont définitivement détruits de la base de données et l'organisateur est redirigé vers la liste de ses parties avec un message de réussite. *(Note : les résultats sont calculés dynamiquement et ne sont pas stockés.)*
3. **Given** la boîte de confirmation est affichée, **When** l'organisateur annule la confirmation, **Then** aucune donnée n'est supprimée et la partie reste active.

---

### User Story 2 - Tentative d'annulation par un utilisateur non propriétaire (Priority: P2)

En tant qu'utilisateur non propriétaire, je ne dois pas pouvoir annuler une partie que je ne possède pas.

**Why this priority**: Empêcher les suppressions non autorisées est essentiel pour la sécurité et la confiance des utilisateurs.

**Independent Test**: Se connecter en tant qu'utilisateur non propriétaire, accéder à l'interface de la partie et vérifier que l'action "Annuler la partie" n'est pas disponible ou que la tentative est rejetée par le système.

**Acceptance Scenarios**:

1. **Given** un utilisateur non propriétaire accède à la page d'une partie, **When** il tente d'appeler l'endpoint d'annulation (ou clique sur un bouton s'il est visible), **Then** l'action est refusée et l'utilisateur reçoit une erreur 403 ou un message expliquant qu'il n'a pas les droits.

---

### User Story 3 - Annulation d'une partie déjà terminée ou introuvable (Priority: P3)

En tant qu'utilisateur, si la partie est déjà terminée ou n'existe plus, l'annulation ne doit pas être possible et l'interface doit renvoyer un message clair.

**Why this priority**: Gérer les cas où la ressource n'existe pas évite les erreurs côté client.

**Independent Test**: Tenter d'annuler une partie terminée ou supprimée et vérifier que l'utilisateur reçoit un message d'erreur approprié.

**Acceptance Scenarios**:

1. **Given** la partie n'existe pas ou est terminée, **When** une requête d'annulation est faite, **Then** le système renvoie une réponse indiquant que l'opération est impossible (404 ou message explicite) et aucune suppression supplémentaire n'est effectuée.

---

### Edge Cases

- Tentative d'annulation simultanée par plusieurs requêtes : la suppression doit rester atomique et aboutir une seule fois.
- Annulation alors que des jobs asynchrones (calculs de résultats, notifications) sont en cours : définir l'ordre d'exécution pour éviter de recréer des enregistrements orphelins.
- Partie avec données volumineuses : vérifier que la suppression complète ne bloque pas le système (voir Assumptions pour stratégie de suppression si nécessaire).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Seul l'**organisateur propriétaire** d'une partie peut initier l'annulation pour cette partie.
- **FR-002**: L'interface doit afficher un **dialogue de confirmation explicite** avant toute suppression irréversible (texte clair, action de confirmation requise).
- **FR-003**: Après confirmation, la partie et tous les enregistrements associés nécessaires (proposals, guesses) doivent être **définitivement supprimés (hard delete)** de la base de données. *(Note : les memberships sont liées à l'équipe, pas à la partie, et ne sont donc pas supprimées.)*
- **FR-004**: L'opération d'annulation doit renvoyer un retour d'état clair : succès (avec message) ou échec (avec raison — droits insuffisants, partie introuvable, erreur serveur).
- **FR-005**: Les tentatives d'annulation par des utilisateurs non propriétaires doivent être rejetées (autorisation vérifiée côté serveur).
- **FR-006**: L'annulation doit être atomique : en cas d'erreur partielle, le système doit garantir la cohérence des données (aucune suppression partielle laissée sans suivi).

### Key Entities *(include if feature involves data)*

- **Partie (Game)**: identifiant, team_id, statut (collecting/guessing/finished), timestamps. *(Propriété indirecte via Team.organizer_id)*
- **Équipe (Team)**: identifiant, organizer_id (FK → User), name
- **Proposal**: game_id, player_id, url — supprimée en cascade lors de l'annulation
- **Guess**: proposal_id, player_id, guessed_author_id — supprimée en cascade via Proposal
- **Utilisateur (User)**: identifiant, relation organisateur via Team

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% des tentatives d'annulation initiées par l'organisateur propriétaire aboutissent à la suppression définitive des données (vérifiable par test d'intégration).
- **SC-002**: 0% des tentatives d'annulation initiées par des non-propriétaires réussissent (les essais doivent être refusés avec code d'autorisation approprié).
- **SC-003**: L'organisateur confirme l'annulation en au plus 2 actions (ouvrir la page → confirmer dans le modal).
- **SC-004**: Après suppression, les pages listant les parties n'affichent plus la partie annulée et toutes les requêtes sur l'identifiant de la partie renvoient 404.

## Assumptions

- Les utilisateurs sont authentifiés et l'application dispose d'un mécanisme d'autorisation pour vérifier la propriété d'une partie.
- "Définitivement détruite" signifie suppression permanente (hard delete). (Decision: hard delete selected in clarifications.) — si l'équipe préfère un soft-delete, indiquer ici et adapter les exigences.
- Les dépendances liées à une partie (guesses, memberships, résultats) doivent aussi être supprimées ; si certaines données doivent être conservées pour audit, indiquer explicitement l'exception.

## Notes

- Si la suppression peut être longue (données volumineuses), envisager d'exécuter l'opération en tâche asynchrone tout en fournissant un retour immédiat à l'utilisateur (par ex. une notification lorsque terminé). Cette décision relève d'un choix d'implémentation et doit rester hors de la spécification fonctionnelle.

```text
# Feature Specification: [FEATURE NAME]

**Feature Branch**: `[###-feature-name]`  
**Created**: [DATE]  
**Status**: Draft  
**Input**: User description: "$ARGUMENTS"

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - [Brief Title] (Priority: P1)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently - e.g., "Can be fully tested by [specific action] and delivers [specific value]"]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]
2. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 2 - [Brief Title] (Priority: P2)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 3 - [Brief Title] (Priority: P3)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right edge cases.
-->

- What happens when [boundary condition]?
- How does system handle [error scenario]?

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: System MUST [specific capability, e.g., "allow users to create accounts"]
- **FR-002**: System MUST [specific capability, e.g., "validate email addresses"]  
- **FR-003**: Users MUST be able to [key interaction, e.g., "reset their password"]
- **FR-004**: System MUST [data requirement, e.g., "persist user preferences"]
- **FR-005**: System MUST [behavior, e.g., "log all security events"]

*Example of marking unclear requirements:*

- **FR-006**: System MUST authenticate users via [NEEDS CLARIFICATION: auth method not specified - email/password, SSO, OAuth?]
- **FR-007**: System MUST retain user data for [NEEDS CLARIFICATION: retention period not specified]

### Key Entities *(include if feature involves data)*

- **[Entity 1]**: [What it represents, key attributes without implementation]
- **[Entity 2]**: [What it represents, relationships to other entities]

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

Include explicit UX consistency and performance criteria per the constitution.

### Measurable Outcomes

- **SC-001**: [Measurable metric, e.g., "Users can complete account creation in under 2 minutes"]
- **SC-002**: [Measurable metric, e.g., "System handles 1000 concurrent users without degradation"]
- **SC-003**: [User satisfaction metric, e.g., "90% of users successfully complete primary task on first attempt"]
- **SC-004**: [Business metric, e.g., "Reduce support tickets related to [X] by 50%"]
