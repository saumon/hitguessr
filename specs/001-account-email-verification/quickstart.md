# Quickstart: Implement Account Email Confirmation (Devise Native)

## Goal

Implement account email confirmation using Devise native Confirmable, keep existing confirmation email template, add runtime feature toggle (ENV/credentials), and document the feature in README in English with a new 1.6.0 entry.

## 1. Database and model

1. Generate and apply a migration adding Devise confirmable columns and indexes to users:
   - confirmation_token (unique index)
   - confirmed_at
   - confirmation_sent_at
   - unconfirmed_email (for reconfirmable)
2. Backfill existing users as confirmed to avoid locking current accounts unexpectedly:
   - set confirmed_at for existing rows during migration/data step.
3. Enable Confirmable in app/models/user.rb devise modules list.

## 2. Devise configuration

1. Set config.confirm_within = 24.hours in config/initializers/devise.rb.
2. Keep config.reconfirmable = true.
3. Ensure case-insensitive email behavior remains enabled.

## 3. Feature toggle (ENV + credentials)

1. Add a small settings resolver (or extend existing mailer settings pattern) for confirmation feature:
   - ENV key first (e.g., ACCOUNT_EMAIL_CONFIRMATION_ENABLED)
   - credentials fallback (e.g., features.account_email_confirmation_enabled)
   - environment default: development false, test/production true.
2. Wire toggle into auth flow:
   - when enabled: enforce Confirmable behavior (unconfirmed cannot sign in).
   - when disabled: bypass confirmation enforcement and email sends for local dev convenience.

## 4. Resend and security behavior

1. Keep Devise resend endpoint (/users/confirmation, POST).
2. Return generic response messaging for unknown emails.
3. Add resend throttle policy: max one resend every 5 minutes per account/email.
4. Keep latest-token validity semantics (old tokens invalid once a new one is issued).

## 5. Mailer template and delivery

1. Reuse existing template at app/views/devise/mailer/confirmation_instructions.html.erb.
2. Validate generated confirmation URLs rely on configured app host/protocol settings.
3. Verify behavior with SMTP configured and non-configured development setups.

## 6. Tests (Minitest)

1. Model/integration tests:
   - registration sends confirmation when toggle enabled.
   - unconfirmed user cannot sign in when toggle enabled.
   - confirmed user can sign in.
   - expired token rejected after 24h.
   - resend generic response for unknown email.
   - resend throttle blocks repeated request inside 5 minutes.
2. Toggle tests:
   - development-default behavior disabled.
   - ENV override takes precedence over credentials.

## 7. README updates (English)

1. Add a dedicated section explaining:
   - what the confirmation feature does,
   - how to enable/disable with ENV and credentials,
   - default behavior in development.
2. Add a new changelog item for version 1.6.0 documenting this feature.

## 8. Validation commands

Run at minimum:

- bin/rails db:migrate
- bin/rails test test/models/user_confirmable_test.rb
- bin/rails test test/integration/account_email_confirmation_flow_test.rb
- bin/rails test test/integration/account_email_confirmation_toggle_test.rb
- bin/rails test test/integration/account_email_confirmation_resend_test.rb

Full suite:

- bin/rails test

### Validation results (2026-04-05)

Targeted auth/confirmation tests run:

```text
29 runs, 85 assertions, 0 failures, 0 errors, 0 skips
```

Full test suite run:

```text
277 runs, 892 assertions, 0 failures, 0 errors, 0 skips
```

All confirmation-specific test vectors passing:

- Toggle enabled/disabled default and ENV override ✓
- Registration sends confirmation email when toggle enabled ✓
- Invalid token rejected (422) ✓
- Expired token (> 24h) rejected (422) ✓
- Unconfirmed user blocked at sign-in ✓
- Sign-in allowed after confirmation ✓
- No auto-resend on failed sign-in ✓
- Resend sends email (outside cooldown) ✓
- Resend generic response for unknown email ✓
- Resend throttle (within 5 minutes) blocks new send ✓
- Latest token valid after resend (old token rejected) ✓
- Case-insensitive email uniqueness enforced ✓

## 9. Rollout notes

1. Enable in production only after SMTP and app URL options are validated.
2. Monitor confirmation email delivery failures and sign-in blocked events in logs
   (`[confirmation] event=...` structured entries).
3. Keep development default disabled to speed local feature work unless explicitly testing confirmation.
4. To manually confirm an account without email access:

   ```bash
   bin/rails runner "User.find_by(email: 'user@example.com')&.confirm"
   ```

## 10. Performance notes (SC-001, SC-002, SC-005)

- **SC-001 (confirmation email dispatch latency)**: Confirmation email is enqueued/sent synchronously
  via Action Mailer with `:test` delivery in tests and SMTP in production. In a production
  environment with SMTP configured, delivery initiation is expected well within 60s.
- **SC-002 (confirmation conversion timing)**: Measured externally (SMTP provider delivery
  receipts / email analytics). Not instrumented in application code.
- **SC-005 (support ticket baseline)**: Establish before enabling in production by querying
  "account created but cannot sign in" tickets in the support system for the 30-day pre-release window.
  Post-release comparison is valid 30 days after rollout.
- **p95 sign-up latency baseline**: Registration in the test suite (toggle on) completes in < 0.3s
  per run. No regression observed vs pre-feature baseline.
