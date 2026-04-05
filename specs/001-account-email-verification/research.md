# Research: Account Email Confirmation (Devise Native)

## Decision 1: Use native Devise Confirmable, no custom token system

- Decision: Enable Devise Confirmable on User and rely on Devise confirmation flows for token generation, storage, expiration, and confirmation.
- Rationale: Matches user requirement to use native Devise mechanism, reduces custom security code, and stays aligned with framework conventions.
- Alternatives considered:
  - Custom activation token model/controller: rejected due to higher security and maintenance risk.
  - Background workflow with external token store: rejected as unnecessary complexity for current scope.

## Decision 2: Feature toggle strategy via ENV and credentials

- Decision: Add a dedicated setting resolved from ENV first, then Rails credentials, with a clear default per environment (development: disabled by default; test/production: enabled unless explicitly overridden).
- Rationale: Supports rapid local testing control and secure centralized deployment config while preserving deterministic precedence.
- Alternatives considered:
  - ENV only: rejected because user explicitly asked for credentials option.
  - Credentials only: rejected because local/test toggling becomes slower and less transparent.

## Decision 3: Keep existing confirmation email template

- Decision: Continue using app/views/devise/mailer/confirmation_instructions.html.erb as the confirmation message body.
- Rationale: User explicitly requested reuse; avoids UX regressions and redundant copy changes.
- Alternatives considered:
  - Replace by generated Devise default template: rejected due to product copy mismatch.
  - Introduce custom mailer class now: rejected because native Devise mailer + existing template is sufficient.

## Decision 4: Enforce anti-enumeration behavior on resend

- Decision: Return a generic response for resend requests whether the email exists or not, and apply resend throttle (1 per 5 minutes per account/email).
- Rationale: Protects against account discovery and email bombing while matching clarified spec constraints.
- Alternatives considered:
  - Explicit "email not found" response: rejected for security.
  - No throttle: rejected for abuse risk.

## Decision 5: Confirmation token validity and resend invalidation

- Decision: Configure confirmation token validity to 24 hours and enforce "latest token wins" semantics through Devise reconfirmation flow and token replacement behavior.
- Rationale: Matches clarified requirement and common security baseline.
- Alternatives considered:
  - 1 hour token: rejected as too aggressive for user friction.
  - Multi-token validity: rejected by clarification.

## Decision 6: Documentation strategy in README (English + versioned)

- Decision: Add an English section documenting confirmation feature behavior and toggle controls (ENV/credentials), plus a new changelog entry for version 1.6.0.
- Rationale: User explicitly requested English documentation and version-tagged entry.
- Alternatives considered:
  - Minimal inline note only: rejected due to discoverability.
  - Separate markdown doc: rejected because user asked README update.
