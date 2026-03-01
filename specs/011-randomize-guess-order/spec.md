# Feature Specification: Randomisation de l’ordre des propositions

**Feature Branch**: `011-randomize-guess-order`  
**Created**: 2026-03-01  
**Status**: Ready  
**Input**: User description: "Lors de la phase de devinette, les propositions doivent être données dans un ordre aléatoire. Sinon, on est capable de deviner qui a proposé quoi, puisque le dernier à avoir proposé est forcément la dernière proposition."

## Clarifications

### Session 2026-03-01

- Q: Quand figer l’ordre si de nouvelles propositions arrivent pendant la phase de devinette ? → A: À l’ouverture de la phase de devinette, les soumissions sont fermées; l’ordre est calculé une fois et ne change plus.
- Q: Comment garantir la cohérence de l’ordre entre joueurs/rechargements (persistance vs recalcul) ? → A: Stocker un ordre figé (positions) par manche au début de la devinette, puis toujours le relire.
- Q: Quel niveau d’exigence pour la stabilité de l’ordre pendant une manche ? → A: Stabilité stricte à 100% (aucune variation tolérée).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Masquer l’ordre de soumission (Priority: P1)

En tant que joueur pendant la phase de devinette, je veux voir les propositions dans un ordre aléatoire afin de ne pas pouvoir déduire l’auteur d’une proposition à partir de sa position.

**Why this priority**: C’est le besoin principal exprimé et il impacte directement l’équité du jeu.

**Independent Test**: Peut être testé en lançant une phase de devinette avec plusieurs propositions et en vérifiant que l’ordre affiché n’est pas celui de soumission.

**Acceptance Scenarios**:

1. **Given** une phase de devinette avec au moins trois propositions soumises dans un ordre connu, **When** un joueur ouvre la liste des propositions, **Then** l’ordre affiché n’expose pas l’ordre chronologique de soumission.
2. **Given** une phase de devinette active, **When** deux joueurs consultent la même liste de propositions pour la même manche, **Then** ils voient le même ordre de propositions pour cette manche.

---

### User Story 2 - Stabilité de l’affichage pendant la manche (Priority: P2)

En tant que joueur, je veux que l’ordre des propositions reste stable pendant ma session de devinette afin d’éviter toute confusion au moment de sélectionner une réponse.

**Why this priority**: Un ordre changeant pendant la manche dégrade l’expérience utilisateur et peut générer des erreurs de sélection.

**Independent Test**: Peut être testé en rechargeant la vue plusieurs fois pendant la même manche et en vérifiant que l’ordre reste identique pour cette manche.

**Acceptance Scenarios**:

1. **Given** un joueur qui consulte la phase de devinette d’une manche, **When** il actualise la page ou revient sur la vue de devinette avant la fin de la manche, **Then** l’ordre des propositions reste identique pour cette manche.

---

### User Story 3 - Continuité du gameplay entre manches (Priority: P3)

En tant que joueur régulier, je veux que la randomisation se fasse à chaque nouvelle manche afin d’éviter des schémas prévisibles d’une manche à l’autre.

**Why this priority**: Assure une équité durable au fil de la partie et réduit l’avantage lié à l’observation des habitudes.

**Independent Test**: Peut être testé en comparant l’ordre des propositions entre plusieurs manches successives avec des ensembles de propositions similaires.

**Acceptance Scenarios**:

1. **Given** deux manches différentes avec des propositions disponibles, **When** un joueur consulte la liste des propositions de chaque manche, **Then** l’ordre est déterminé indépendamment pour chaque manche.

### Edge Cases

- Que se passe-t-il si la manche contient 0 ou 1 proposition: l’interface reste fonctionnelle et ne tente pas de randomisation inutile.
- Que se passe-t-il si un joueur tente de soumettre une proposition après l’ouverture de la phase de devinette: la soumission est refusée car la manche est figée pour garantir un ordre stable et commun.
- Que se passe-t-il en cas d’égalités de temps de soumission ou de soumissions quasi simultanées: aucun indice d’auteur ne doit être inférable depuis la position affichée.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT afficher les propositions de la phase de devinette dans un ordre non corrélé à l’ordre de soumission.
- **FR-002**: Le système DOIT appliquer un ordre unique par manche de devinette, partagé de façon cohérente entre tous les joueurs de cette manche.
- **FR-003**: Le système DOIT conserver le même ordre affiché tout au long d’une manche donnée, y compris après rechargement de la vue par un joueur.
- **FR-004**: Le système DOIT recalculer l’ordre de manière indépendante à chaque nouvelle manche.
- **FR-005**: Le système DOIT gérer les cas avec 0 ou 1 proposition sans erreur d’affichage ni comportement incohérent.
- **FR-006**: Le système NE DOIT PAS exposer à l’utilisateur final des informations permettant d’associer la position d’une proposition à son moment de soumission.
- **FR-007**: Le système DOIT fermer les soumissions à l’ouverture de la phase de devinette, puis figer l’ordre des propositions pour toute la durée de la manche.
- **FR-008**: Le système DOIT persister l’ordre figé des propositions par manche et DOIT réutiliser cet ordre persistant pour tous les affichages de la manche (tous joueurs, tous rechargements).

### Non-Functional Requirements

- **NFR-001 (Performance)**: Le rendu de la page de devinettes (`GET /games/:game_id/guesses/new`) DOIT respecter un p95 inférieur à 200 ms pour une manche contenant jusqu’à 30 propositions en environnement de test local.
- **NFR-002 (Performance)**: L’assignation initiale et la persistance de l’ordre au passage `collecting -> guessing` DOIT rester inférieure à 100 ms (p95) pour une manche contenant jusqu’à 30 propositions en environnement de test local.
- **NFR-003 (UX Consistency & Accessibility)**: La randomisation de l’ordre NE DOIT PAS introduire de nouveau composant d’interaction dans le flux de devinette et DOIT préserver la navigabilité clavier ainsi que la lisibilité des feedbacks existants.

### Key Entities *(include if feature involves data)*

- **Manche de devinette**: Segment de jeu actif dans lequel les joueurs voient et évaluent les propositions; possède un identifiant et une fenêtre temporelle.
- **Proposition**: Contenu soumis par un joueur pour une manche donnée; possède un auteur, un moment de soumission et une position d’affichage en phase de devinette.
- **Ordre d’affichage de manche**: Séquence des propositions présentées aux joueurs pour une manche donnée; est figée au début de la devinette, persistée, puis relue à chaque affichage de la manche.

## Assumptions

- La randomisation est requise uniquement pendant la phase de devinette.
- L’ordre affiché doit être identique pour tous les joueurs sur une même manche afin d’éviter toute ambiguïté dans les échanges.
- L’exigence porte sur l’ordre visible par l’utilisateur, indépendamment des mécanismes internes de stockage.
- La transition vers la phase de devinette clôt la collecte de nouvelles propositions pour la manche en cours.

## Dependencies

- Dépend de la disponibilité d’un identifiant de manche permettant d’appliquer un ordre propre à chaque manche.
- Dépend du flux de soumission des propositions existant, avec arrêt des soumissions au passage en phase de devinette.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Dans 100% des manches observées en validation, la dernière proposition affichée n’est pas systématiquement celle soumise en dernier.
- **SC-002**: Dans 100% des tests multi-joueurs sur une même manche, tous les joueurs voient le même ordre de propositions.
- **SC-003**: Dans 100% des vérifications par rechargement de page sur une manche active, l’ordre reste strictement identique pour le joueur.
- **SC-004**: Sur un échantillon d’au moins 10 joueurs testeurs et 20 manches, 90% ou plus des réponses à la question standardisée « Pouvez-vous déduire l’auteur via la position ? » sont « Non ».
- **SC-005**: Sur un protocole de 20 mesures en environnement de test local, le p95 de `GET /games/:game_id/guesses/new` reste inférieur à 200 ms pour 30 propositions.
- **SC-006**: Sur un protocole de 20 mesures en environnement de test local, le p95 d’assignation/persistance de l’ordre au passage en devinette reste inférieur à 100 ms pour 30 propositions.
