# Feature Specification: Alerte de doublon de proposition

**Feature Branch**: `[013-duplicate-guess-warning]`  
**Created**: 2026-03-02  
**Status**: Shipped  
**Input**: User description: "Lors de la phase de devinette, on doit pouvoir proposer la même personne pour plusieurs vidéos, mais lors de la soumission, je veux avoir un warning me l'indiquant. Pour une proposition donnée, si un nom a déjà été sélectionné dans une autre proposition, on doit avoir un indicateur permettant de signaler que ce nom a déjà été proposé. Cet indicateur doit donc évoluer en temps réel en fonction des propositions."

## Clarifications

### Session 2026-03-02

- Q: Quel format d'avertissement à la soumission est attendu en cas de doublon ? → A: Étape de confirmation bloquante uniquement s’il y a doublon (modal avec « Annuler » / « Confirmer »).
- Q: Où doit vivre la logique de détection des doublons ? → A: Détection uniquement côté client (UI).
- Q: Quelle normalisation de nom faut-il appliquer pour détecter un doublon ? → A: Aucune normalisation ; comparaison stricte de la valeur sélectionnée (dans l'UI actuelle: identifiant de joueur).
- Q: Quelles informations doivent apparaître dans la modal d’avertissement ? → A: La modal liste les doublons détectés (nom + propositions concernées).

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

### User Story 1 - Signaler les doublons en temps réel (Priority: P1)

En tant que joueur en phase de devinette, je veux voir immédiatement si le nom saisi pour une vidéo a déjà été proposé ailleurs, afin d'éviter les doublons non intentionnels avant la soumission.

**Why this priority**: C'est la valeur principale demandée: améliorer la qualité des propositions au moment de la saisie.

**Independent Test**: Peut être testé entièrement en modifiant les noms sur plusieurs propositions et en vérifiant que l'indicateur de doublon apparaît, disparaît et se met à jour sans soumission.

**Acceptance Scenarios**:

1. **Given** un joueur avec plusieurs propositions vides, **When** il sélectionne le même nom sur deux propositions différentes, **Then** chaque proposition concernée affiche un indicateur de nom déjà proposé.
2. **Given** deux propositions marquées comme doublons, **When** le joueur change l'une des deux propositions vers un nom unique, **Then** l'indicateur de doublon se met à jour en temps réel et disparaît là où il n'y a plus de conflit.

---

### User Story 2 - Avertir à la soumission (Priority: P2)

En tant que joueur, je veux un avertissement explicite lors de la soumission si ma grille contient des doublons de noms, afin de confirmer mon choix en connaissance de cause.

**Why this priority**: Même avec l'indicateur en temps réel, un rappel final limite les erreurs de soumission.

**Independent Test**: Peut être testé en soumettant une grille avec au moins un doublon puis une grille sans doublon, et en comparant le comportement d'avertissement.

**Acceptance Scenarios**:

1. **Given** une grille contenant au moins un nom en doublon, **When** le joueur déclenche la soumission, **Then** une modal de confirmation avec « Annuler » et « Confirmer » est affichée avant soumission finale et liste les doublons détectés (nom + propositions concernées).
2. **Given** une grille sans doublon, **When** le joueur déclenche la soumission, **Then** aucun avertissement de doublon n'est affiché.

---

### User Story 3 - Autoriser les doublons intentionnels (Priority: P3)

En tant que joueur, je veux pouvoir conserver des doublons si je le souhaite, afin de garder ma liberté stratégique.

**Why this priority**: La demande impose un warning et un indicateur, pas un blocage.

**Independent Test**: Peut être testé en soumettant volontairement une grille avec doublons après affichage du warning.

**Acceptance Scenarios**:

1. **Given** une grille avec doublons, **When** le joueur confirme la soumission malgré l'avertissement, **Then** la soumission est acceptée.

---

### Edge Cases

- Le même nom est sélectionné sur plus de deux propositions: toutes les propositions concernées doivent être signalées.
- Le joueur remplace un nom doublonné par un nom déjà présent ailleurs: l'indicateur doit refléter le nouvel ensemble de conflits en moins d'une seconde.
- Le joueur vide une proposition précédemment doublonnée: les indicateurs restants doivent être recalculés immédiatement.
- Seules les sélections strictement identiques (même joueur sélectionné) sont considérées comme doublons.
- Aucun nom sélectionné sur la grille: aucun avertissement de doublon ne doit être affiché.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT permettre de sélectionner le même nom pour plusieurs propositions durant la phase de devinette.
- **FR-002**: Le système DOIT détecter en continu les sélections répétées sur plusieurs propositions de la même grille.
- **FR-003**: Le système DOIT afficher, pour chaque proposition concernée, un indicateur visible lorsque sa sélection est en doublon avec au moins une autre proposition.
- **FR-004**: Le système DOIT retirer l'indicateur de doublon pour une proposition dès qu'elle ne partage plus sa sélection avec une autre proposition.
- **FR-005**: Le système DOIT mettre à jour les indicateurs de doublon dès chaque modification de nom, sans action supplémentaire de l'utilisateur.
- **FR-006**: Lors d'une tentative de soumission d'une grille contenant au moins un doublon, le système DOIT ouvrir une modal de confirmation bloquante avec les actions « Annuler » et « Confirmer » avant la soumission finale.
- **FR-007**: Lors d'une tentative de soumission d'une grille sans doublon, le système NE DOIT PAS afficher l'avertissement de doublon.
- **FR-008**: Après affichage de la modal d'avertissement, le joueur DOIT pouvoir confirmer et soumettre quand même une grille contenant des doublons.
- **FR-009**: La logique de détection de doublons DOIT comparer la valeur de sélection en égalité stricte, sans normalisation supplémentaire (dans l'UI actuelle: même `guessed_author_id`).
- **FR-010**: La détection des doublons utilisée pour l'indicateur temps réel et l'ouverture de la modal de confirmation DOIT être exécutée uniquement côté client.
- **FR-011**: La modal d'avertissement DOIT lister chaque nom en doublon et les propositions concernées pour ce nom.

### Key Entities *(include if feature involves data)*

- **Proposition de devinette**: Une entrée associée à une vidéo, contenant le nom sélectionné par le joueur.
- **Nom sélectionné**: Valeur de personne choisie pour une proposition; sert de base à la détection des doublons entre propositions d'une même grille.
- **État de doublon de la grille**: Vue consolidée des propositions qui partagent un même nom à un instant donné.

### Assumptions

- Le warning de soumission impose une étape de confirmation bloquante (modal), mais n'interdit pas la soumission finale en cas de doublon.
- Aucune revalidation serveur des doublons n'est requise au moment de la soumission.
- Les doublons sont évalués uniquement à l'intérieur de la grille courante d'un joueur, pas entre joueurs différents.
- Le comportement attendu est identique sur les écrans desktop et mobile déjà supportés.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Dans 95% des interactions de saisie, l'indicateur de doublon se met à jour en moins d'une seconde après un changement de nom.
- **SC-002**: 100% des soumissions contenant au moins un doublon affichent un avertissement avant confirmation finale.
- **SC-003**: 100% des soumissions sans doublon n'affichent aucun avertissement de doublon.
- **SC-004**: Lors d'un test utilisateur guidé, au moins 90% des joueurs identifient correctement la présence d'un doublon avant soumission.
