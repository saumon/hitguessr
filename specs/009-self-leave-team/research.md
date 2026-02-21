# Phase 0 Research — Quitter son équipe

## Décision 1 — Endpoint auto-service dédié

- **Decision**: Exposer une route dédiée `DELETE /teams/:team_id/leave` vers `MembershipsController#leave`, sans `membership_id` côté client.
- **Rationale**: Le flux auto-service ne doit pas permettre de cibler un autre membre (FR-013/FR-014). Une route dédiée sépare clairement ce cas du `destroy` organisateur existant.
- **Alternatives considered**:
  - Réutiliser `memberships#destroy` avec contraintes supplémentaires.
  - Utiliser `resource :membership` imbriqué (moins explicite dans ce contexte avec route existante `destroy`).

## Décision 2 — Ciblage strict de l'utilisateur courant

- **Decision**: Dans l'action `leave`, cibler uniquement l'appartenance `current_user` sur l'équipe ciblée.
- **Rationale**: Empêche toute suppression d'un tiers via paramètres manipulés, conforme aux exigences de sécurité fonctionnelle.
- **Alternatives considered**:
  - Charger une appartenance via ID soumis par client, même vérifiée ensuite.
  - Double lookup `Team.find + membership.find` (plus complexe sans valeur ajoutée).

## Décision 3 — Source d'autorité organisateur

- **Decision**: Refuser la sortie si `team.organizer_id == current_user.id`.
- **Rationale**: Clarification fonctionnelle explicite et source d'autorité unique déjà présente dans le modèle `Team`.
- **Alternatives considered**:
  - Introduire un rôle organisateur dans `Membership`.
  - Vérification via objet `team.organizer == current_user` (équivalente, mais moins alignée littéralement à la clarification).

## Décision 4 — Blocage pendant partie active

- **Decision**: Refuser la sortie si l'équipe a une partie active (`collecting` ou `guessing`) via `team.has_active_game?`.
- **Rationale**: Évite des incohérences de participation pendant la partie; la logique existe déjà (`Game.active`).
- **Alternatives considered**:
  - Autoriser pendant `collecting` uniquement.
  - Autoriser toujours et corriger après coup (risqué métier).

## Décision 5 — UX de l'action Quitter

- **Decision**: Bouton libellé exact `Quitter`, placé dans la zone d'actions d'en-tête avec le même style/position que `Supprimer`, et confirmation Turbo exacte `Êtes-vous sûr de vouloir quitter cette équipe ?`.
- **Rationale**: Respect strict de la contrainte produit et cohérence UX avec les actions destructives existantes.
- **Alternatives considered**:
  - Lien texte dans la section membres.
  - Modale custom Stimulus (sur-dimensionné pour ce besoin).

## Décision 6 — Redirection et feedback

- **Decision**: Sur succès, rediriger vers `teams#index` avec message de confirmation; sur refus, rediriger vers la page équipe (ou `teams#index` si inaccessible) avec message explicite.
- **Rationale**: Conformité FR-012 + patterns de feedback déjà utilisés (`flash notice/alert`).
- **Alternatives considered**:
  - Rester systématiquement sur `team#show` après succès.
  - Réponse Turbo Stream (complexité non nécessaire).

## Décision 7 — Stratégie de tests minimale robuste

- **Decision**: Couvrir la feature avec tests contrôleur/intégration (succès, refus organisateur, refus partie active, idempotence) + tests système ciblés UX (`Quitter` visible membre, masqué organisateur, confirmation exacte).
- **Rationale**: Respect de la constitution (testing non-négociable) avec coûts maîtrisés et forte confiance de régression.
- **Alternatives considered**:
  - Tout couvrir en system tests (plus lent et plus fragile).
  - Uniquement tests manuels (insuffisant).

## Décision 8 — Documentation produit

- **Decision**: Mettre à jour le README global (Features + API route + section Changelog) et ajouter l'entrée de version pour cette feature dans le changelog déjà présent dans `README.md`.
- **Rationale**: Le projet centralise déjà le changelog dans le README; cela répond à la demande sans créer de surface documentaire redondante.
- **Alternatives considered**:
  - Créer un `CHANGELOG.md` séparé.
  - Documenter seulement dans la spec feature.
