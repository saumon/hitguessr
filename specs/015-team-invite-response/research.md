# Phase 0 — Research: Gestion des invitations d’équipe

## Decision 1: Introduire une entité dédiée `TeamInvitation`

- **Decision**: Créer un nouveau modèle/table `team_invitations` pour porter le cycle de vie invitation (`pending`, `accepted`, `refused`) au lieu de surcharger `memberships`.
- **Rationale**: Le modèle actuel `memberships` représente déjà l’appartenance active et alimente le reste du produit (compte membres, lancement de partie, permissions). Isoler les invitations réduit le risque de régression transversale.
- **Alternatives considered**:
  - Ajouter `status` à `memberships` (rejeté: impact élevé sur toutes les requêtes existantes et ambiguïté entre adhésion et invitation).
  - Table générique d’événements (rejeté: trop complexe pour ce besoin focalisé).

## Decision 2: Garder `Membership` comme source unique des membres actifs

- **Decision**: `Membership` reste l’unique source de vérité des membres actifs; l’acceptation d’invitation crée l’adhésion active à ce moment précis.
- **Rationale**: Compatible avec la logique actuelle (`team.members`, minimum de membres, actions gameplay), et conforme à FR-002/FR-006/SC-004.
- **Alternatives considered**:
  - Matérialiser les actifs via requête sur invitations acceptées (rejeté: complexifie la lecture et la perf sur écrans critiques).

## Decision 3: Endpoints HTML orientés actions métier

- **Decision**: Ajouter un contrôleur `InvitationsController` avec actions `create`, `accept`, `refuse` (soumissions formulaire + redirect/flash).
- **Rationale**: Le produit est aujourd’hui en flux Rails server-rendered (pas d’API JSON publique nécessaire pour cette feature).
- **Alternatives considered**:
  - Réutiliser `MembershipsController#create` pour invitation et ajouter des actions de réponse (rejeté: responsabilité mixte, risque de confusion domaine).
  - API JSON + front JS dédié (rejeté: surdimensionné pour le scope).

## Decision 4: Concurrence — première réponse gagnante

- **Decision**: Appliquer une transition atomique `pending -> accepted/refused` via update conditionnel en transaction; toute réponse ultérieure échoue proprement.
- **Rationale**: Répond à FR-013 et évite des états incohérents en cas de double soumission/latence.
- **Alternatives considered**:
  - Dernière écriture gagnante (rejeté: non déterministe et non conforme clarification).
  - Verrouillage optimiste seul (rejeté: nécessite gestion d’exception supplémentaire; update conditionnel suffit ici).

## Decision 5: Visibilité et permissions strictes côté serveur

- **Decision**: Appliquer les règles d’accès au niveau contrôleur + chargement ciblé des collections pour la vue `/teams`.
- **Rationale**: Empêche l’exposition d’invitations hors périmètre et garantit FR-012/FR-015/FR-016 même si l’UI est contournée.
- **Alternatives considered**:
  - Masquage purement front-end (rejeté: insuffisant pour la sécurité).

## Decision 6: Documentation versionnée `v1.3.0` dans `README.md`

- **Decision**: Documenter la feature dans la section Features et ajouter une entrée Changelog `v1.3.0`.
- **Rationale**: Exigence explicite utilisateur; garantit la traçabilité produit dès la livraison.
- **Alternatives considered**:
  - Changelog séparé hors README (rejeté: non demandé et non aligné avec la pratique actuelle du repo).
