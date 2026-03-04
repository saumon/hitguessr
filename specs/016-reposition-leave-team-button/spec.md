# Feature Specification: Repositionnement du bouton quitter l’équipe

**Feature Branch**: `016-reposition-leave-team-button`  
**Created**: 2026-03-04  
**Status**: Shipped  
**Input**: User description: "Le placement du bouton 'Quitter' n'est pas optimal, un membre d'une équipe risque de cliquer dessus par inadvertance. Le bouton 'Quitter' doit donc être déplacé au niveau de la liste des membres, aligné à droite. Pour plus de clarté, le bouton doit de plus être renommé en 'Quitter l'équipe'."

## Clarifications

### Session 2026-03-04

- Q: Où placer exactement le bouton dans la section membres ? → A: Sur la ligne du membre connecté, aligné à droite.
- Q: Quel comportement responsive appliquer en petit écran ? → A: Afficher le bouton sur une seconde ligne sous les infos du membre, aligné à droite.
- Q: Sur quelles lignes membres afficher le bouton ? → A: Uniquement sur la ligne du membre connecté.
- Q: Comment gérer le libellé en interface multilingue ? → A: Libellé localisé par langue, avec fallback "Quitter l'équipe".

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Réduire les clics accidentels (Priority: P1)

En tant que membre d’une équipe, je veux que l’action de sortie d’équipe soit positionnée sur ma ligne de membre dans la section des membres et alignée à droite, afin de limiter les clics involontaires.

**Why this priority**: Cette action est potentiellement destructrice pour l’utilisateur; son emplacement doit prioritairement réduire le risque d’erreur.

**Independent Test**: Peut être testé en affichant la page d’équipe pour un membre actif et en vérifiant que l’action de sortie n’apparaît plus à son emplacement précédent et qu’elle est visible dans la zone de liste des membres, alignée à droite.

**Acceptance Scenarios**:

1. **Given** un membre actif consulte sa page d’équipe, **When** sa ligne de membre est affichée dans la section de liste des membres, **Then** l’action de sortie d’équipe est positionnée sur cette ligne, alignée à droite.
2. **Given** un membre actif consulte la page d’équipe, **When** il parcourt la zone où se trouvait auparavant l’action de sortie, **Then** l’action n’est plus affichée à cet ancien emplacement.

---

### User Story 2 - Clarifier le libellé de l’action (Priority: P2)

En tant que membre d’une équipe, je veux un libellé explicite et localisé de l’action de sortie pour comprendre immédiatement sa portée.

**Why this priority**: Un libellé explicite réduit l’ambiguïté et améliore la compréhension avant l’action.

**Independent Test**: Peut être testé en affichant la page d’équipe d’un membre actif et en vérifiant que le texte affiché correspond à la locale active; si aucune traduction n’est disponible, le libellé affiché est "Quitter l'équipe".

**Acceptance Scenarios**:

1. **Given** un membre actif voit l’action de sortie d’équipe, **When** le libellé est rendu, **Then** le texte affiché correspond au libellé localisé de la locale active ou, à défaut, à "Quitter l'équipe".
2. **Given** un membre actif utilise l’action "Quitter l'équipe", **When** l’action est déclenchée, **Then** le comportement métier de sortie d’équipe reste identique au comportement existant.

---

### User Story 3 - Conserver la lisibilité de la liste des membres (Priority: P3)

En tant que membre d’une équipe, je veux que l’action "Quitter l'équipe" s’intègre visuellement à la zone des membres sans masquer les informations de la liste.

**Why this priority**: Le changement d’emplacement ne doit pas dégrader l’expérience de consultation de la composition de l’équipe.

**Independent Test**: Peut être testé en affichant une équipe avec plusieurs membres et en vérifiant que la liste reste lisible et que l’action reste identifiable à droite.

**Acceptance Scenarios**:

1. **Given** une équipe avec plusieurs membres, **When** la page est affichée, **Then** les informations de chaque membre restent visibles et l’action "Quitter l'équipe" est clairement séparée des lignes de membres.

### Edge Cases

- Le membre est le seul membre de l’équipe: l’action "Quitter l'équipe" reste visible sur sa ligne, alignée à droite.
- La liste des membres est longue: l’action reste alignée à droite sur la ligne du membre connecté et ne chevauche pas les informations affichées.
- L’utilisateur n’est pas membre actif de l’équipe: l’action "Quitter l'équipe" n’est pas affichée.
- Une variation de langue/interface existe: le libellé suit la traduction de la locale active; en cas d’absence de traduction, le fallback est "Quitter l'équipe".
- En petit écran, l’action "Quitter l'équipe" passe sur une seconde ligne sous les informations du membre connecté et reste alignée à droite.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système MUST afficher l’action de sortie d’équipe sur la ligne du membre connecté dans la liste des membres.
- **FR-002**: Le système MUST aligner visuellement cette action à droite sur la ligne du membre connecté.
- **FR-003**: Le système MUST ne plus afficher cette action à son emplacement précédent sur la page d’équipe.
- **FR-004**: Le système MUST afficher un libellé localisé pour l’action de sortie d’équipe selon la locale active, avec fallback "Quitter l'équipe" si la traduction est absente.
- **FR-005**: Les utilisateurs MUST pouvoir déclencher l’action de sortie via ce nouveau bouton sans changement de comportement métier par rapport à l’existant.
- **FR-006**: Le système MUST conserver la lisibilité des informations de la liste des membres après le déplacement de l’action.
- **FR-007**: Le système MUST n’afficher l’action "Quitter l'équipe" qu’aux membres actifs ayant le droit de quitter l’équipe.
- **FR-008**: En petit écran, le système MUST afficher l’action "Quitter l'équipe" sur une seconde ligne sous les informations du membre connecté, alignée à droite.
- **FR-009**: La livraison MUST inclure une entrée de changelog dans `README.md` pour la version `1.3.3`, décrivant cette feature.
- **FR-010**: Le système MUST respecter un budget de performance pour cette feature: la réponse de l’action de sortie d’équipe (`DELETE /teams/:team_id/leave`) reste ≤ 2 secondes au p95 dans l’environnement de test du projet.

### Key Entities *(include if feature involves data)*

- **Membre d’équipe**: Représente un utilisateur appartenant à une équipe et pouvant, selon son statut, voir l’action de sortie.
- **Équipe**: Représente le groupe affichant la liste de ses membres, zone dans laquelle l’action "Quitter l'équipe" est positionnée.
- **Action de sortie d’équipe**: Représente l’action utilisateur permettant de quitter l’équipe, avec un libellé explicite et un emplacement dédié.

### Assumptions

- Le flux métier de sortie d’équipe existe déjà et doit rester inchangé.
- La page affichant la liste des membres est le point d’usage principal pour cette action.
- Les règles d’autorisation existantes déterminant qui peut quitter une équipe restent inchangées.
- La demande concerne uniquement le positionnement et le libellé de l’action, sans ajout de nouvelle étape de confirmation.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% des vues d’équipe pour un membre autorisé affichent l’action sur la ligne du membre connecté, alignée à droite.
- **SC-002**: 100% des occurrences du bouton utilisent le libellé localisé de la locale active ou le fallback "Quitter l'équipe" si aucune traduction n’est disponible.
- **SC-003**: 100% des tests de non-régression du flux de sortie d’équipe passent avec le nouveau positionnement.
- **SC-004**: Lors d’une revue UX interne sur un panel de 10 testeurs minimum, au moins 90% des testeurs identifient correctement la finalité de l’action sans ambiguïté après exécution d’un scénario standardisé (ouvrir équipe → ouvrir section membres → repérer l’action de sortie).
- **SC-005**: 100% des vues d’équipe en petit écran affichent l’action sous les informations du membre connecté, alignée à droite, sans chevauchement visuel.
- **SC-006**: 100% des vues d’équipe n’affichent l’action "Quitter l'équipe" que sur la ligne du membre connecté (aucune autre ligne membre ne contient cette action).
- **SC-007**: Le `README.md` contient une entrée de changelog version `1.3.3` mentionnant explicitement le repositionnement du bouton de sortie d’équipe.
- **SC-008**: Sur 20 exécutions du flux de sortie d’équipe en environnement de test stable, au moins 19 réponses sont rendues en ≤ 2 secondes.
