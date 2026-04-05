require "test_helper"

# Tests d'intégration pour la feature 001: Activation de compte par email
#
# Couvre (toggle activé par défaut en test) :
#   US1 — Confirmation après inscription
#   US2 — Blocage connexion avant activation
class AccountEmailConfirmationFlowTest < ActionDispatch::IntegrationTest
  setup do
    ActionMailer::Base.deliveries.clear
    @original_toggle = Rails.application.config.x.account_email_confirmation_enabled
    Rails.application.config.x.account_email_confirmation_enabled = true
  end

  teardown do
    Rails.application.config.x.account_email_confirmation_enabled = @original_toggle
  end

  # =========================================================
  # T020 [US1] — Confirmation email sent on sign-up when toggle enabled
  # =========================================================

  test "confirmation email is sent on sign-up when toggle is enabled" do
    assert_difference "ActionMailer::Base.deliveries.count", 1 do
      post user_registration_path, params: {
        user: {
          name: "Alice",
          email: "alice@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    mail = ActionMailer::Base.deliveries.last
    assert_not_nil mail
    assert_includes mail.to, "alice@example.com"
    assert_match(/confirmation_token=/, mail.html_part&.body&.to_s || mail.body.to_s)
  end

  # =========================================================
  # T021 [US1] — Successful account activation via valid token
  # =========================================================

  test "account is activated via valid confirmation token" do
    user = create_unconfirmed_user("bob@example.com")
    token = extract_confirmation_token_from_deliveries

    get user_confirmation_path, params: { confirmation_token: token }

    user.reload
    assert_not_nil user.confirmed_at
    assert_redirected_to root_path
  end

  # =========================================================
  # T022 [US1] — Invalid/expired confirmation token rejection
  # =========================================================

  test "invalid confirmation token is rejected with error" do
    get user_confirmation_path, params: { confirmation_token: "totally_invalid_token_xyz" }

    assert_response :unprocessable_entity
  end

  test "expired confirmation token is rejected" do
    user = create_unconfirmed_user("carol@example.com")
    token = extract_confirmation_token_from_deliveries

    # Fast-forward beyond 24h token validity
    user.update_column(:confirmation_sent_at, 25.hours.ago)

    get user_confirmation_path, params: { confirmation_token: token }

    assert_response :unprocessable_entity
    user.reload
    assert_nil user.confirmed_at
  end

  # =========================================================
  # T028 [US2] — Sign-in denied for unconfirmed user when toggle enabled
  # =========================================================

  test "unconfirmed user cannot sign in when toggle is enabled" do
    user = create_unconfirmed_user("dave@example.com", password: "password123")

    post user_session_path, params: {
      user: { email: "dave@example.com", password: "password123" }
    }

    # Should be redirected back to sign-in, not authenticated
    assert_redirected_to new_user_session_path
    follow_redirect!
    assert_match(/confirm/i, response.body)
  end

  # =========================================================
  # T029 [US2] — Sign-in allowed after confirmation
  # =========================================================

  test "confirmed user can sign in" do
    user = create_unconfirmed_user("eve@example.com", password: "password123")
    user.confirm

    post user_session_path, params: {
      user: { email: "eve@example.com", password: "password123" }
    }

    assert_redirected_to root_path
  end

  # =========================================================
  # T053 [US2] — Failed sign-in of unconfirmed user does NOT trigger auto-resend
  # =========================================================

  test "failed sign-in for unconfirmed user does not trigger automatic resend" do
    user = create_unconfirmed_user("frank@example.com", password: "password123")
    deliveries_before = ActionMailer::Base.deliveries.count

    post user_session_path, params: {
      user: { email: "frank@example.com", password: "password123" }
    }

    # No new email should have been sent
    assert_equal deliveries_before, ActionMailer::Base.deliveries.count
  end

  private

  def create_unconfirmed_user(email, password: "password123")
    ActionMailer::Base.deliveries.clear
    post user_registration_path, params: {
      user: { name: "Test User", email: email, password: password, password_confirmation: password }
    }
    User.find_by!(email: email)
  end

  def extract_confirmation_token_from_deliveries
    mail = ActionMailer::Base.deliveries.last
    body = mail.html_part&.body&.to_s || mail.body.to_s
    body.match(/confirmation_token=([A-Za-z0-9_\-]+)/)[1]
  end
end
