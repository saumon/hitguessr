# Feature Specification: HitGuessr - jeu de devinettes musicales en équipe

**Feature Branch**: `001-hitguessr-gameplay`  
**Created**: 2026-01-31  
**Status**: Draft  
**Input**: User description: "Je veux construire un site web nommé \"HitGuessr\" dont voici le principe : celui-ci permet à des joueurs d'une équipe de proposer des liens de musique (YouTube ou autre). Chaque joueur propose sa musique sans le dire aux autres. A l'issue de la phase de récolte des propositions, tous les joueurs doivent deviner qui a proposé quelle musique. Lorsque toutes les propositions sont faites, le jeu est terminé et un classement est ainsi établi. Le but du jeu est donc de trouver au plus juste qui a proposé quelle musique. Celui qui a un maximum de bonnes réponses a un meilleur score. Une équipe est créée par un organisateur. L'organisateur choisit qui sont les membres de l'équipe. Seul l'organisateur peut lancer une campagne de jeu et la terminer. L'organisateur est considéré lui aussi comme un joueur pour le jeu en cours. Il peut donc aussi proposer une musique sans voir ce que les autres ont proposé. Lorsque tous les joueurs ont proposé leur titre de musique, le jeu en cours passe dans la phase où chaque joueur doit deviner qui a dit quoi. A l'issue de cette phase de proposition, la partie est terminée et le score est donc affiché."

## Clarifications

### Session 2026-01-31

- Q: Que faire si l’organisateur clôture la collecte alors qu’un ou plusieurs joueurs n’ont pas proposé de musique ? → A: Exclure ces joueurs du pool de propositions (ils n’apparaissent pas en devinettes) et leur score final est 0.
- Q: Comment gérer des liens musicaux dupliqués entre joueurs ? → A: Interdire les doublons et demander une nouvelle proposition.
- Q: Que se passe-t-il si un joueur ne soumet pas ses devinettes avant la fin de la phase ? → A: Soumission manquante = score 0, mais la partie se termine.
- Q: Que se passe-t-il si l’organisateur tente de lancer la phase de devinettes alors que des propositions manquent ? → A: Autoriser la transition en excluant les joueurs sans proposition du pool de propositions.
- Q: Comment gérer les égalités au classement final ? → A: Ex aequo (même rang, même score).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Créer une équipe et collecter les propositions (Priority: P1)

En tant qu’organisateur, je crée une équipe, sélectionne ses membres et lance une partie pour collecter une proposition musicale de chaque joueur, y compris moi-même.

**Why this priority**: Sans collecte structurée des propositions, le jeu ne peut pas démarrer ni générer de valeur.

**Independent Test**: Testable en lançant une partie, en faisant soumettre une proposition par chaque membre, puis en vérifiant que toutes les propositions sont enregistrées et restent invisibles aux autres joueurs.

**Acceptance Scenarios**:

1. **Given** une équipe créée par un organisateur avec des membres définis, **When** l’organisateur lance une partie, **Then** chaque membre peut soumettre une proposition musicale unique pour cette partie.
2. **Given** une partie en phase de collecte, **When** un joueur soumet sa proposition, **Then** il ne peut pas voir les propositions des autres joueurs.
3. **Given** une partie en phase de collecte, **When** tous les joueurs ont soumis leur proposition, **Then** la partie devient éligible au passage en phase de devinettes.

---

### User Story 2 - Deviner qui a proposé quelle musique (Priority: P2)

En tant que joueur, je participe à la phase de devinettes en associant chaque proposition musicale à un membre de l’équipe.

**Why this priority**: C’est le cœur du jeu et la source principale de valeur ludique.

**Independent Test**: Testable en ouvrant la phase de devinettes, en associant chaque proposition à un membre, puis en validant une soumission de devinettes complète.

**Acceptance Scenarios**:

1. **Given** une partie en phase de devinettes, **When** un joueur ouvre la liste des propositions, **Then** il voit des propositions anonymisées sans indication d’auteur.
2. **Given** une partie en phase de devinettes, **When** un joueur associe chaque proposition à un membre et soumet ses réponses, **Then** ses réponses sont enregistrées et verrouillées.

---

### User Story 3 - Afficher résultats et classement (Priority: P3)

En tant que joueur, je consulte les résultats et le classement final une fois la partie terminée.

**Why this priority**: Le feedback et le classement donnent une conclusion claire au jeu et motivent la rejouabilité.

**Independent Test**: Testable en clôturant la phase de devinettes et en vérifiant l’affichage des scores et du classement.

**Acceptance Scenarios**:

1. **Given** une partie terminée, **When** un joueur ouvre les résultats, **Then** il voit pour chaque proposition le véritable auteur et son propre résultat.
2. **Given** une partie terminée, **When** les scores sont affichés, **Then** un classement ordonné par score est visible pour tous les membres.

---

### Edge Cases

- Si un joueur n’a pas soumis de proposition avant la clôture, il est exclu du pool de propositions en phase de devinettes et obtient un score final de 0.
- Si un joueur ne soumet pas ses devinettes avant la fin de la phase, sa soumission est considérée manquante, son score est 0, et la partie se termine.
- Les liens musicaux dupliqués sont interdits et le joueur doit soumettre une nouvelle proposition.
- Si l’organisateur lance la phase de devinettes avec des propositions manquantes, la transition est autorisée et les joueurs sans proposition sont exclus du pool de propositions.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT permettre à un organisateur de créer une équipe et d’en définir les membres.
- **FR-002**: Le système DOIT considérer l’organisateur comme un joueur participant dans la partie.
- **FR-003**: Seul l’organisateur DOIT pouvoir lancer et terminer une partie.
- **FR-004**: Chaque joueur DOIT pouvoir soumettre une unique proposition musicale par partie.
- **FR-005**: Les propositions musicales DOIVENT rester invisibles aux autres joueurs pendant la phase de collecte.
- **FR-006**: La partie DOIT passer en phase de devinettes uniquement après la clôture de la collecte par l’organisateur.
- **FR-007**: En phase de devinettes, chaque joueur DOIT pouvoir associer chaque proposition à un membre de l’équipe.
- **FR-008**: Une soumission de devinettes DOIT être complète pour être validée (toutes les propositions associées).
- **FR-009**: Après validation, les devinettes d’un joueur DOIVENT être verrouillées.
- **FR-010**: Le système DOIT calculer un score par joueur basé sur le nombre d’associations correctes.
- **FR-011**: Le système DOIT afficher les résultats détaillés et un classement final à la fin de la partie.
- **FR-011a**: En cas d’égalité de score, le classement DOIT afficher les joueurs ex aequo avec le même rang.
- **FR-012**: Le système DOIT gérer explicitement les cas d’absence de proposition ou de devinettes selon les règles définies dans les hypothèses.

### Key Entities *(include if feature involves data)*

- **Utilisateur**: Personne identifiée pouvant rejoindre une équipe, proposer une musique et faire des devinettes.
- **Équipe**: Groupe de joueurs défini par un organisateur.
- **Partie**: Session de jeu avec phases (collecte, devinettes, terminé).
- **Proposition musicale**: Lien musical soumis par un joueur pour une partie.
- **Devinette**: Association d’un joueur entre une proposition musicale et un membre.
- **Score**: Résultat numérique d’un joueur calculé à partir des associations correctes.

### Assumptions

- Les joueurs disposent déjà d’un compte et peuvent être sélectionnés par l’organisateur.
- Une partie correspond à une seule proposition musicale par joueur.
- Les liens musicaux dupliqués sont refusés et nécessitent une nouvelle proposition.
- L’organisateur peut clôturer une phase même si tous les joueurs n’ont pas soumis leurs réponses.
- Une absence de proposition ou de devinettes donne un score nul pour le joueur concerné et l’exclut du pool de propositions en phase de devinettes (si pas de proposition), tout en permettant la fin de partie.

### Dependencies

- Gestion des identités utilisateurs et appartenance à une équipe disponible au moment du lancement de la partie.

### Scope

**In Scope**:

- Une partie unique avec une proposition musicale par joueur.
- Phases de collecte, devinettes, résultats.
- Classement final basé sur les associations correctes.

**Out of Scope**:

- Tournois multi-parties ou saisons.
- Messagerie ou chat entre joueurs.
- Modération avancée du contenu musical.

## Success Criteria *(mandatory)*

Include explicit UX consistency and performance criteria per the constitution.

### Measurable Outcomes

- **SC-001**: 95% des joueurs soumettent leur proposition en moins de 2 minutes, sans assistance.
- **SC-002**: 95% des joueurs soumettent des devinettes complètes en moins de 5 minutes pour une partie standard.
- **SC-003**: 90% des joueurs comprennent le passage des phases (collecte → devinettes → résultats) sans aide externe lors d’un test utilisateur.
- **SC-004**: Les résultats et le classement s’affichent en moins de 2 secondes pour 95% des sessions.
- **SC-005**: Zéro incohérence UX de sévérité élevée détectée sur les écrans principaux lors de la revue UX.
