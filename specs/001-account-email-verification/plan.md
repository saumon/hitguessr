# Implementation Plan: Activation de compte par email

**Branch**: `001-account-email-verification` | **Date**: 2026-04-05 | **Spec**: `/specs/001-account-email-verification/spec.md`
**Input**: Feature specification from `/specs/001-account-email-verification/spec.md`

## Summary

Implémenter l'activation de compte email avec le mécanisme natif Devise Confirmable, en conservant le template existant `app/views/devise/mailer/confirmation_instructions.html.erb`. Ajouter un mécanisme de feature toggle pilotable par variable d'environnement et par credentials pour activer/désactiver l'envoi + blocage avant confirmation (désactivé par défaut en développement). Compléter la documentation en anglais dans le README avec une entrée de changelog 1.6.0.

## Technical Context

**Language/Version**: Ruby 3.4.6 + Rails 8.1.3  
**Primary Dependencies**: Devise 5.0 (Confirmable), Action Mailer, Active Record, Hitguessr::MailerSettings  
**Storage**: SQLite via Active Record (dev/test), compatible RDBMS en production  
**Testing**: Rails Minitest (model, controller/integration, system)  
**Target Platform**: Application web Rails monolithique (Puma, Docker/Kamal)  
**Project Type**: Web application monolithique Rails  
**Performance Goals**: conserver un flux d'inscription interactif sans régression sensible (p95 web sur inscription non dégradé de >10% vs baseline locale), livraison du mail de confirmation sous 60s en environnement SMTP opérationnel  
**Constraints**: utiliser le mécanisme natif Devise et le template email existant; lien valide 24h; dernier lien uniquement valide après renvoi; réponse anti-énumération générique; rate limit renvoi 5 minutes; toggle via ENV ou credentials avec défaut development désactivé  
**Scale/Scope**: modèle User + migration confirmable, flux d'inscription/connexion/confirmation Devise, configuration applicative, logs d'événements, tests Minitest, documentation README en anglais (feature + changelog 1.6.0)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Code quality: portée bornée aux zones auth/email/config/doc, architecture alignée avec conventions Rails/Devise
- [x] Testing: stratégie définie pour inscription, blocage connexion non confirmée, confirmation, renvoi, rate limit, toggle on/off
- [x] UX consistency: utilisation des écrans/messages Devise existants + message générique anti-énumération
- [x] Performance: budget explicite sur inscription et objectif d'envoi email sous 60s avec instrumentation logs
- [x] Quality gates: exécution ciblée tests Minitest + suite/auth checks CI projet

## Project Structure

### Documentation (this feature)

```text
specs/001-account-email-verification/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── email-confirmation.openapi.yaml
└── tasks.md
```

### Source Code (repository root)

```text
app/
├── controllers/
│   └── users/
│       ├── confirmations_controller.rb
│       └── sessions_controller.rb
├── models/
│   └── user.rb
└── views/
    └── devise/mailer/confirmation_instructions.html.erb

config/
├── environments/
│   ├── development.rb
│   ├── test.rb
│   └── production.rb
├── initializers/
│   └── devise.rb
└── mailer_settings.rb

db/
├── migrate/
└── schema.rb

test/
├── models/
├── integration/
└── system/

README.md
```

**Structure Decision**: conserver la structure monolithique Rails existante et concentrer l'implémentation sur Devise Confirmable, la configuration toggle, la migration utilisateur, les tests Minitest et la documentation produit.

## Phase 0 Research Output

Voir `/specs/001-account-email-verification/research.md` pour les décisions sur:

- stratégie Devise Confirmable native
- design du toggle ENV/credentials et valeurs par défaut
- politique de sécurité (anti-énumération, rate limit, token)
- plan de documentation README en anglais (feature + changelog 1.6.0)

## Phase 1 Design Output

Voir:

- `/specs/001-account-email-verification/data-model.md`
- `/specs/001-account-email-verification/contracts/email-confirmation.openapi.yaml`
- `/specs/001-account-email-verification/quickstart.md`

## Post-Design Constitution Check

- [x] Code quality: design final centré sur primitives natives Devise + adaptation minimale de config
- [x] Testing: couverture prévue pour toggle off/on, confirmation success/failure, renvoi, blocage connexion
- [x] UX consistency: template email existant conservé, feedback utilisateur explicite et cohérent Devise
- [x] Performance: contraintes de latence et d'envoi documentées; pas de mécanisme custom lourd ajouté
- [x] Quality gates: quickstart inclut exécution tests auth + vérifications documentation

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
| --------- | ---------- | ----------------------------------- |
| None | N/A | N/A |
