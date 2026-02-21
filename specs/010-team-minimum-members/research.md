# Phase 0 Research — Seuil minimum de membres pour démarrer une partie

## Decision 1 — Enforcer la règle au niveau modèle (invariant de création)

- **Decision**: Implémenter la règle "minimum 3 membres" dans `Game` via une validation `on: :create`, en complément des règles déjà présentes.
- **Rationale**: Les invariants de création sont déjà portés par le modèle (`only_one_active_game_per_team`). Le contrôle uniquement en contrôleur serait contournable.
- **Alternatives considered**:
  - Contrôle uniquement dans `GamesController#create` (rejeté: couverture incomplète des points d'entrée).
  - Service object dédié (rejeté: surdimensionné pour une règle unique).

## Decision 2 — Vérification transactionnelle côté serveur

- **Decision**: Exécuter la vérification du seuil dans la même transaction que la création effective de partie.
- **Rationale**: Évite les courses entre lecture de l'effectif et insertion de la partie (TOCTOU), en cohérence avec la clarification FR-010.
- **Alternatives considered**:
  - Validation hors transaction (rejeté: risque de course).
  - Vérification post-création avec rollback logique (rejeté: complexité inutile).

## Decision 3 — Définition opérationnelle de "membres actifs/confirmés"

- **Decision**: Dans ce schéma, un membre actif/confirmé correspond à un `Membership` existant entre `User` et `Team`.
- **Rationale**: Le modèle `Membership` n'a pas de statut; Devise `confirmable` n'est pas activé. Le seul signal fiable est l'existence de la relation.
- **Alternatives considered**:
  - Ajouter un statut de membership (rejeté: hors scope de la feature).
  - Utiliser une confirmation email Devise (rejeté: non activé dans l'application).

## Decision 4 — UX: feedback explicite sans déléguer l'autorité au client

- **Decision**: Conserver la décision finale côté serveur et afficher un message explicite en succès/refus; UI informative (état bouton/message) mais non autoritaire.
- **Rationale**: Empêche les contournements et garde une expérience claire pour l'organisateur.
- **Alternatives considered**:
  - Blocage uniquement UI (rejeté: non sécurisé).
  - Message générique sans raison (rejeté: confusion utilisateur).

## Decision 5 — Stratégie de tests minimaux robustes

- **Decision**: Couvrir la feature via tests `model + controller + system` avec focus sur le seuil frontière (2 vs 3 membres).
- **Rationale**: Équilibre fiabilité/coût; respecte la constitution (tests non négociables) et les patterns du repo.
- **Alternatives considered**:
  - Uniquement tests système (rejeté: plus lent/fragile).
  - Uniquement tests contrôleur (rejeté: UX non couverte).

## Decision 6 — Performance et mesure SC-003

- **Decision**: Utiliser un comptage membership direct (`COUNT`) et valider que le feedback utilisateur reste dans le budget SC-003.
- **Rationale**: Requête simple et indexée, impact faible; la mesure de temps de réponse reste traçable dans les tests/scénarios d'acceptation.
- **Alternatives considered**:
  - Pas de mesure explicite (rejeté: non aligné constitution/performance).
  - Instrumentation lourde dédiée (rejeté: disproportionnée au scope).

## Decision 7 — Documentation produit en anglais

- **Decision**: Mettre à jour `README.md` (features + règles + routes + changelog) en anglais avec entrée dédiée à #010.
- **Rationale**: Le README est la source documentaire produit visible du repo, incluant déjà le changelog.
- **Alternatives considered**:
  - Documentation uniquement dans la spec feature (rejeté: faible visibilité).
  - Ne pas toucher le changelog (rejeté: demande explicite non couverte).

## SC-003 Measurement Evidence (T029)

- **Date**: 2026-02-21
- **Environment**: `bin/rails runner -e test` with authenticated integration session
- **Sample size**: 20 launch attempts (10 success with eligible team, 10 refusal with ineligible team)
- **Raw latency samples (ms)**: 6.76, 1.18, 0.72, 0.61, 0.84, 1.85, 1.20, 0.58, 0.64, 0.70, 0.60, 0.50, 0.65, 1.44, 0.91, 0.54, 0.63, 0.49, 0.57, 0.49
- **Computed p95**: 1.85 ms
- **Rate <= 2000ms**: 100.0%

Conclusion: SC-003 is satisfied in the measured feature scenario.
