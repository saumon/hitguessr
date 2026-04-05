require "test_helper"

# Tests d'intégration pour la feature 001: Renvoi de l'email de confirmation
#
# Couvre :
#   T035 — Renvoi sur compte non confirmé
#   T036 — Réponse générique pour email inconnu (anti-énumération)
#   T037 — Throttle de renvoi (cooldown 5 minutes)
#   T038 — Seul le dernier token est valide après renvoi
class AccountEmailConfirmationResendTest < ActionDispatch::IntegrationTest
  setup do
    ActionMailer::Base.deliveries.clear
    @original_toggle = Rails.application.config.x.account_email_confirmation_enabled
    Rails.application.config.x.account_email_confirmation_enabled = true
  end

  teardown do
    Rails.application.config.x.account_email_confirmation_enabled = @original_toggle
  end

  # =========================================================
  # T035 — Resend confirmation on unconfirmed account
  # =========================================================

  test "resend sends a new confirmation email for an unconfirmed account" do
    user = create_unconfirmed_user("ivan@example.com")
    # Expire the cooldown so throttle does not block the resend
    user.update_column(:confirmation_sent_at, 6.minutes.ago)
    ActionMailer::Base.deliveries.clear

    assert_difference "ActionMailer::Base.deliveries.count", 1 do
      post user_confirmation_path, params: { user: { email: "ivan@example.com" } }
    end

    assert_redirected_to new_user_session_path
    mail = ActionMailer::Base.deliveries.last
    assert_includes mail.to, "ivan@example.com"
  end

  # =========================================================
  # T036 — Generic response on unknown email (anti-enumeration)
  # =========================================================

  test "resend returns generic response for unknown email" do
    assert_no_difference "ActionMailer::Base.deliveries.count" do
      post user_confirmation_path, params: { user: { email: "nobody@example.com" } }
    end

    # Response is same generic redirect regardless of email existence
    assert_redirected_to new_user_session_path
  end

  test "resend returns generic response for already-confirmed account" do
    user = create_confirmed_user("judy@example.com")
    ActionMailer::Base.deliveries.clear

    assert_no_difference "ActionMailer::Base.deliveries.count" do
      post user_confirmation_path, params: { user: { email: "judy@example.com" } }
    end

    assert_redirected_to new_user_session_path
  end

  # =========================================================
  # T037 — Resend throttle: 5-minute cooldown
  # =========================================================

  test "resend within 5-minute cooldown does not send another email" do
    user = create_unconfirmed_user("kevin@example.com")
    # confirmation_sent_at is now set from create
    ActionMailer::Base.deliveries.clear

    # First resend — within cooldown window
    assert_no_difference "ActionMailer::Base.deliveries.count" do
      post user_confirmation_path, params: { user: { email: "kevin@example.com" } }
    end

    assert_redirected_to new_user_session_path
  end

  test "resend is allowed after cooldown window expires" do
    user = create_unconfirmed_user("leo@example.com")
    # Simulate that the last confirmation was sent >5 minutes ago
    user.update_column(:confirmation_sent_at, 6.minutes.ago)
    ActionMailer::Base.deliveries.clear

    assert_difference "ActionMailer::Base.deliveries.count", 1 do
      post user_confirmation_path, params: { user: { email: "leo@example.com" } }
    end

    assert_redirected_to new_user_session_path
  end

  # =========================================================
  # T038 — Latest confirmation token wins after resend
  # =========================================================

  test "old token is invalid after resend; new token confirms the account" do
    user = create_unconfirmed_user("mia@example.com")
    token1 = extract_confirmation_token_from_deliveries

    # Expire the token (> 24h) so that resend generates a NEW token (Devise reuses valid tokens).
    # Also ensures no throttle (sent 25h ago > 5min cooldown).
    user.update_column(:confirmation_sent_at, 25.hours.ago)
    ActionMailer::Base.deliveries.clear

    post user_confirmation_path, params: { user: { email: "mia@example.com" } }
    token2 = extract_confirmation_token_from_deliveries

    assert_not_equal token1, token2, "resend should generate a new token"

    # Old token should be rejected
    get user_confirmation_path, params: { confirmation_token: token1 }
    assert_response :unprocessable_entity

    user.reload
    assert_nil user.confirmed_at

    # New token should succeed
    get user_confirmation_path, params: { confirmation_token: token2 }
    user.reload
    assert_not_nil user.confirmed_at
  end

  private

  def create_unconfirmed_user(email)
    ActionMailer::Base.deliveries.clear
    post user_registration_path, params: {
      user: { name: "Test", email: email, password: "password123", password_confirmation: "password123" }
    }
    User.find_by!(email: email)
  end

  def create_confirmed_user(email)
    user = User.new(name: "Test Confirmed", email: email, password: "password123")
    user.skip_confirmation!
    user.save!
    user
  end

  def extract_confirmation_token_from_deliveries
    mail = ActionMailer::Base.deliveries.last
    body = mail.html_part&.body&.to_s || mail.body.to_s
    body.match(/confirmation_token=([A-Za-z0-9_\-]+)/)[1]
  end
end
