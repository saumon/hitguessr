# Phase 0 Research — Autonomie des membres d'équipe

## Decision 1 — Élargir les actions de progression à tous les membres (organisateur inclus)

- **Decision**: Autoriser `create game`, `start_guessing` et `finish` à tout utilisateur membre de l’équipe, y compris l’organisateur.
- **Rationale**: Répond directement au besoin de continuité quand l’organisateur est absent, sans retirer les droits existants de l’organisateur.
- **Alternatives considered**:
  - Autoriser uniquement les membres non organisateurs (rejeté: régression potentielle des droits organisateur et logique de rôle plus complexe).
  - Conserver organisateur-only (rejeté: ne répond pas à la valeur métier principale).

## Decision 2 — Conserver les actions critiques en organisateur-only

- **Decision**: Garder `cancel game` et `add/remove membership` strictement réservées à l’organisateur.
- **Rationale**: Actions de gouvernance sensibles avec impact structurel sur équipe/partie; alignement direct FR-004/FR-005.
- **Alternatives considered**:
  - Autoriser annulation par tout membre (rejeté: risque de sabotage involontaire de partie active).
  - Autoriser gestion membres à tous (rejeté: perte de contrôle d’équipe et sécurité sociale faible).

## Decision 3 — Contrôle d’accès systématique côté serveur avec redirection explicite

- **Decision**: Vérifier permission + appartenance au moment de l’exécution de chaque action et rediriger vers écran équipe/partie avec message clair en cas de refus.
- **Rationale**: Empêche le contournement UI par URL directe, compatible avec le pattern HTML/Turbo existant (redirect + flash).
- **Alternatives considered**:
  - UI-only guards (rejeté: insuffisant côté sécurité).
  - Page 403 dédiée sans redirection (rejeté: moins fluide pour un produit majoritairement orienté interface).

## Decision 4 — Masquer complètement les actions non autorisées dans l’UI

- **Decision**: Ne pas afficher les actions interdites au rôle courant (pas de version disabled).
- **Rationale**: Réduit la confusion et les tentatives inutiles, et respecte la clarification adoptée.
- **Alternatives considered**:
  - Boutons désactivés avec info-bulle (rejeté: surcharge visuelle et incitation à l’erreur).
  - Boutons visibles/actifs puis refus serveur (rejeté: mauvaise UX et bruit d’erreurs).

## Decision 5 — Concurrence: refus explicite de la seconde transition

- **Decision**: Lors de requêtes quasi simultanées sur la même transition, appliquer une seule transition et refuser la suivante avec conflit explicite “état déjà changé”.
- **Rationale**: Préserve l’intégrité d’état et rend le cas concurrent testable/observable (SC-005).
- **Alternatives considered**:
  - Succès idempotent silencieux de la seconde requête (rejeté: masque la course et brouille les diagnostics).
  - Mise en file d’attente/retry automatique (rejeté: complexité hors scope).

## Decision 6 — Réutiliser le verrouillage domaine existant pour l’intégrité

- **Decision**: S’appuyer sur les garde-fous de transitions (`Game::InvalidTransitionError`, `with_lock` existant sur auto-progression) et ajouter une gestion explicite du conflit dans les actions manuelles.
- **Rationale**: Correction à la racine avec effort minimal, cohérente avec le domaine actuel.
- **Alternatives considered**:
  - Nouveau mécanisme de lock applicatif global (rejeté: surdimensionné pour ce flux).
  - Verrouillage uniquement en base au niveau contrôleur (rejeté: plus fragile et moins lisible métier).

## Decision 7 — Stratégie de tests multi-couches

- **Decision**: Couvrir la feature par tests modèle, contrôleur et système:
  - permissions progression membre/organisateur,
  - refus actions réservées,
  - refus hors équipe/URL directe,
  - conflit de transition concurrente,
  - visibilité UI conditionnelle des actions.
- **Rationale**: Respecte la constitution (tests non négociables) et limite les régressions sur les flux clés.
- **Alternatives considered**:
  - Uniquement tests système (rejeté: plus lents et diagnostics moins précis).
  - Uniquement tests contrôleur (rejeté: ne valide pas la cohérence UX de masquage).

## Decision 8 — Budgets performance et critères opérationnels

- **Decision**: Utiliser comme cibles:
  - 95% des transitions autorisées visibles utilisateur en < 2s (SC-004),
  - 0 double transition appliquée sur 200 essais (SC-005),
  - p95 réponse serveur endpoints de transition < 300ms en nominal.
- **Rationale**: Aligne explicitement la feature avec les critères de succès et la constitution performance.
- **Alternatives considered**:
  - Aucun budget mesuré (rejeté: non conforme constitution).
  - Instrumentation APM complète immédiate (rejeté: hors scope plan feature).

## Decision 9 — Documentation produit obligatoire dans README + changelog v1.2.3

- **Decision**: Planifier la mise à jour de [README.md](../../README.md) dans:
  - section `Features` (autonomie membres d’équipe),
  - section `Roles`/permissions,
  - section `Changelog` avec entrée `v1.2.3` référencée vers `#012`.
- **Rationale**: Le projet centralise déjà la documentation de release dans le README; la demande utilisateur impose ce livrable.
- **Alternatives considered**:
  - Fichier changelog séparé (rejeté: absent du repo et incohérent avec l’existant).
  - Documentation uniquement dans spec (rejeté: visibilité produit insuffisante).
