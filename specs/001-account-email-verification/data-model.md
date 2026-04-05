# Data Model: Account Email Confirmation

## Entity: User (existing, extended with Confirmable)

- Purpose: authenticated account identity, now with confirmation lifecycle managed by Devise.
- Storage: users table.

### Fields

- id: integer, primary key.
- email: string, required, globally unique, case-insensitive (downcased by Devise via `case_insensitive_keys`). Unique index on users.email enforced at DB level.
- encrypted_password: string, required.
- name: string, required.
- confirmed_at: datetime, nullable until activation, set on successful confirmation. Pre-existing rows backfilled to `created_at` by migration `20260405100002`.
- confirmation_token: string, nullable transient, unique when present. Unique index on users.confirmation_token enforced at DB level. Token is regenerated on each resend once the previous one is expired (`confirm_within = 24.hours`).
- confirmation_sent_at: datetime, nullable, set each time a confirmation email is issued (also used for 5-minute resend cooldown check in `Users::ConfirmationsController`).
- unconfirmed_email: string, nullable, used by Devise reconfirmable flows when a confirmed user changes their email.
- remember_created_at, reset_password_token, reset_password_sent_at: existing Devise fields.
- created_at, updated_at: timestamps.

### Validation rules

- email uniqueness must remain strict at database level.
- email normalization/case-insensitive auth remains via Devise case_insensitive_keys.
- user cannot authenticate when feature toggle is enabled and confirmed_at is null.

### State transitions

- Registered-Unconfirmed:
  - Entry: account creation when confirmation feature enabled.
  - Exit: successful confirmation with valid token.
- Confirmed:
  - Entry: confirmed_at set after token validation.
  - Behavior: normal sign-in allowed.
- Confirmation-Expired:
  - Condition: current time beyond confirmation_sent_at + 24h with no confirmation.
  - Behavior: token rejected, resend needed.
- Reconfirmation-Pending (existing Devise behavior):
  - Trigger: user changes email when reconfirmable enabled.

## Entity: ConfirmationDeliveryPolicy (configuration entity)

- Purpose: centralize runtime behavior for confirmation feature activation and resend protections.
- Storage: derived from ENV and Rails credentials (no dedicated table).

### Fields (logical configuration)

- enabled: boolean toggle for account confirmation enforcement and mail send.
  Resolution: `Rails.application.config.x.account_email_confirmation_enabled` (set per environment at boot by `Hitguessr::MailerSettings.confirmation_feature_enabled?`).
- resend_cooldown_seconds: 300 (hardcoded in `Users::ConfirmationsController::RESEND_COOLDOWN_SECONDS`). Cooldown checked against `confirmation_sent_at`.
- confirm_within_hours: 24. Configured as `config.confirm_within = 24.hours` in `config/initializers/devise.rb`.
- anti_enumeration_generic_response: true. Implemented in `Users::ConfirmationsController#create`: generic redirect to `new_user_session_path` regardless of outcome.

### Resolution precedence

1. Environment variable value.
2. Rails credentials value.
3. Environment-specific default (development false, test/production true unless overridden).

## Relationships

- User 1 -> N confirmation email sends over time (event stream/logical history).
- Only the most recently issued confirmation token for a user is accepted (latest-token validity semantics).

## Derived events (for logging and support)

- confirmation_email_sent
- confirmation_email_resent
- confirmation_succeeded
- confirmation_failed_invalid_or_expired
- sign_in_blocked_unconfirmed
- resend_throttled
