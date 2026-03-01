# Phase 0 Research — Randomisation de l’ordre des propositions

## Decision 1 — Persister l’ordre sur `Proposal`

- **Decision**: Ajouter un champ entier `guess_order_position` sur `proposals`, assigné une seule fois au passage en phase `guessing`.
- **Rationale**: Garantit un ordre stable, partagé et relisible sans recalcul à chaque requête; minimise l’empreinte technique.
- **Alternatives considered**:
  - Table dédiée `guess_orders` (rejeté: complexité relationnelle inutile pour une séquence simple).
  - Seed déterministe recalculé à la volée (rejeté: risque de divergence inter-processus/évolutions d’algorithme).

## Decision 2 — Calculer l’ordre au `start_guessing!`

- **Decision**: Générer et persister l’ordre dans `Game#start_guessing!`, dans le même flux transactionnel que la transition d’état.
- **Rationale**: Le moment métier est explicite (freeze au début de la devinette), cohérent avec FR-007/FR-008.
- **Alternatives considered**:
  - Calcul au premier `GET /guesses/new` (rejeté: première-lecture non déterministe sous concurrence).
  - Calcul lors de chaque création de proposition (rejeté: inutile pendant `collecting`, plus fragile).

## Decision 3 — Génération aléatoire et unicité de rang

- **Decision**: Mélanger les IDs de propositions une fois (Ruby `shuffle`) puis assigner des positions consécutives 1..N.
- **Rationale**: Suffisant pour casser la corrélation avec l’ordre de soumission; positions explicites et testables.
- **Alternatives considered**:
  - Tri aléatoire SQL (`ORDER BY RANDOM()`) à chaque requête (rejeté: non stable et coûteux).
  - RNG cryptographique dédiée (rejeté: valeur ajoutée faible pour ce cas de jeu).

## Decision 4 — Lecture ordonnée unique dans le flux de devinettes

- **Decision**: Dans `GuessesController#new`, charger les propositions à deviner triées par `guess_order_position ASC`, puis `id ASC` en fallback.
- **Rationale**: Affichage déterministe, stable au reload et homogène entre joueurs.
- **Alternatives considered**:
  - Tri par `created_at` (rejeté: fuit l’ordre de soumission).
  - Tri uniquement en mémoire côté vue (rejeté: dépend du chargement et du contexte runtime).

## Decision 5 — Soumissions tardives interdites sans nouveau mécanisme

- **Decision**: Conserver le verrou fonctionnel existant (`collecting?` requis) comme garde de refus des propositions après entrée en devinette.
- **Rationale**: Le comportement existe déjà côté contrôleur + validation modèle; il couvre FR-007 sans complexité supplémentaire.
- **Alternatives considered**:
  - Nouveau flag de verrouillage dédié (rejeté: redondant avec l’état de partie).

## Decision 6 — Couverture de tests minimale mais complète

- **Decision**: Couvrir la feature via tests `model + controller + system`:
  - ordre assigné et stable,
  - ordre commun entre joueurs,
  - indépendance entre manches,
  - refus des soumissions hors collecte,
  - edge cases 0/1 proposition.
- **Rationale**: Respecte la constitution (tests non négociables) et les patterns de test du repo.
- **Alternatives considered**:
  - Uniquement tests système (rejeté: trop lents/fragiles pour logique de persistance).
  - Uniquement tests modèle (rejeté: ne valide pas le rendu utilisateur).

## Decision 7 — Budget performance et mesure

- **Decision**: Budget p95 `<200ms` pour `GET /games/:id/guesses/new` (jusqu’à 30 propositions), et `<100ms` pour l’assignation initiale de l’ordre lors de `start_guessing!`.
- **Rationale**: Aligne la feature avec la constitution (performance explicite + vérifiable) sans instrumentation lourde.
- **Alternatives considered**:
  - Aucune mesure (rejeté: non conforme à la constitution).
  - Instrumentation APM dédiée (rejeté: hors scope).

## Decision 8 — Documentation produit et versionning

- **Decision**: Mettre à jour `README.md` (section Features + Rules + Changelog) avec une entrée `v1.2.2` référencée vers `#011`.
- **Rationale**: Le README contient déjà le changelog officiel du projet.
- **Alternatives considered**:
  - Changelog séparé (rejeté: absent du repo).
  - Doc uniquement dans la spec feature (rejeté: visibilité insuffisante).
