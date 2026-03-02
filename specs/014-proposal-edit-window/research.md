# Research — Modification de proposition avant guessing

## Decision 1: Autoriser l’édition uniquement en phase `collecting`

- Decision: Conserver le garde-fou métier sur la phase active au moment de la soumission et refuser toute tentative en `guessing`.
- Rationale: Couvre FR-001, FR-003, FR-004 et FR-007; protège l’équité après verrouillage.
- Alternatives considered: Vérification seulement à l’ouverture du formulaire (rejetée: vulnérable aux transitions de phase pendant l’édition).

## Decision 2: Utiliser un flux unique de type upsert pour la proposition du joueur

- Decision: Le même flux accepte la création en `collecting` si aucune proposition n’existe, sinon met à jour la proposition existante.
- Rationale: Clarification validée (création autorisée via flux “modifier”) et UX simplifiée.
- Alternatives considered: Séparer strictement création et modification (rejetée: complexité UX/API inutile).

## Decision 3: Ne conserver que la valeur courante (pas d’historisation)

- Decision: Aucune table/history additionnelle; la dernière valeur soumise remplace la précédente.
- Rationale: Clarification validée; minimise complexité et impact base.
- Alternatives considered: Historique complet ou partiel (rejetés: hors besoin métier explicite).

## Decision 4: Préserver les règles d’autorisation existantes

- Decision: Les checks d’appartenance équipe et de propriété restent inchangés; aucune élévation de privilèges.
- Rationale: Couvre FR-006 et edge case “joueur non membre”.
- Alternatives considered: Assouplir les droits pour accélérer la feature (rejetée: régression sécurité/équité).

## Decision 5: Gérer explicitement la course de transition de phase

- Decision: Décider l’acceptation/rejet à l’instant de soumission (contrôleur + validations modèle), y compris si l’UI a été ouverte avant la bascule.
- Rationale: Couvre User Story 3 et edge case principal.
- Alternatives considered: Tolérer une “grâce” après bascule (rejetée: contredit la demande de verrouillage immédiat).

## Decision 6: Maintenir la documentation produit dans README/changelog

- Decision: Décrire la feature dans `README.md` et ajouter l’entrée de version `v1.2.3`.
- Rationale: Exigence explicite utilisateur et traçabilité release.
- Alternatives considered: Documentation limitée à `specs/` (rejetée: ne satisfait pas la demande).
