require "test_helper"

# Tests d'intégration pour la feature 001: Toggle de confirmation email
#
# Couvre :
#   T019 — Précédence ENV > credentials pour la résolution du toggle
#   T030 — Mode toggle désactivé : connexion autorisée sans confirmation
class AccountEmailConfirmationToggleTest < ActionDispatch::IntegrationTest
  setup do
    ActionMailer::Base.deliveries.clear
    @original_toggle = Rails.application.config.x.account_email_confirmation_enabled
  end

  teardown do
    Rails.application.config.x.account_email_confirmation_enabled = @original_toggle
    ENV.delete("ACCOUNT_EMAIL_CONFIRMATION_ENABLED")
  end

  # =========================================================
  # T019 — ENV takes precedence over credentials/default
  # =========================================================

  test "ENV ACCOUNT_EMAIL_CONFIRMATION_ENABLED=false overrides default true" do
    ENV["ACCOUNT_EMAIL_CONFIRMATION_ENABLED"] = "false"
    result = Hitguessr::MailerSettings.confirmation_feature_enabled?(default: true)
    assert_equal false, result
  end

  test "ENV ACCOUNT_EMAIL_CONFIRMATION_ENABLED=true overrides default false" do
    ENV["ACCOUNT_EMAIL_CONFIRMATION_ENABLED"] = "true"
    result = Hitguessr::MailerSettings.confirmation_feature_enabled?(default: false)
    assert_equal true, result
  end

  test "default value is used when ENV is absent and credentials unset" do
    ENV.delete("ACCOUNT_EMAIL_CONFIRMATION_ENABLED")
    result_true  = Hitguessr::MailerSettings.confirmation_feature_enabled?(default: true)
    result_false = Hitguessr::MailerSettings.confirmation_feature_enabled?(default: false)
    assert_equal true,  result_true
    assert_equal false, result_false
  end

  # =========================================================
  # T030 [US2] — Toggle disabled: sign-in without confirmation allowed
  # =========================================================

  test "unconfirmed user can sign in when toggle is disabled" do
    Rails.application.config.x.account_email_confirmation_enabled = false

    user = User.new(name: "Grace", email: "grace_toggle@example.com", password: "password123")
    user.skip_confirmation_notification!
    user.save!
    # user has no confirmed_at but toggle is off

    post user_session_path, params: {
      user: { email: "grace_toggle@example.com", password: "password123" }
    }

    assert_redirected_to root_path
  end

  test "confirmation email is NOT sent on sign-up when toggle is disabled" do
    Rails.application.config.x.account_email_confirmation_enabled = false

    assert_no_difference "ActionMailer::Base.deliveries.count" do
      post user_registration_path, params: {
        user: {
          name: "Heidi",
          email: "heidi_toggle@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
  end
end
