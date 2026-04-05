# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # Sign-in blocking for unconfirmed users (T031) is enforced at the model level via:
  #   User#confirmation_required?    — reflects the runtime feature toggle state.
  #   User#active_for_authentication? — (Devise::Confirmable) returns false when
  #     confirmation_required? is true and confirmed_at is nil.
  #   User#inactive_message           — returns :unconfirmed and emits an audit log entry.
  #
  # Toggle bypass path (T032): when the feature toggle is disabled
  # (Rails.application.config.x.account_email_confirmation_enabled = false),
  # User#confirmation_required? returns false. Devise skips confirmation enforcement and
  # all users can sign in regardless of confirmation status (local dev default).
  #
  # No automatic resend on failed sign-in (T054): this controller does not invoke any
  # resend logic. Failed-authentication redirects are handled exclusively by Devise's
  # failure app, preserving the contract that sign-in failure has no resend side-effect.
end
