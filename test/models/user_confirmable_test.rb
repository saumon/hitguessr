require "test_helper"

# Tests unitaires pour la feature 001: Activation de compte par email (modèle User)
#
# Couvre :
#   T018 — Champs confirmable présents et backfill correct
#   T023 — Comportement confirm_within 24h
#   T055 — Unicité email insensible à la casse
class UserConfirmableTest < ActiveSupport::TestCase
  setup do
    @original_toggle = Rails.application.config.x.account_email_confirmation_enabled
    Rails.application.config.x.account_email_confirmation_enabled = true
  end

  teardown do
    Rails.application.config.x.account_email_confirmation_enabled = @original_toggle
  end

  # =========================================================
  # T018 — Foundational confirmable field tests
  # =========================================================

  test "User has confirmable columns after migration" do
    columns = User.column_names
    assert_includes columns, "confirmation_token"
    assert_includes columns, "confirmed_at"
    assert_includes columns, "confirmation_sent_at"
    assert_includes columns, "unconfirmed_email"
  end

  test "new user is unconfirmed when toggle is enabled" do
    user = User.new(name: "Test", email: "newuser_model@example.com", password: "password123")
    user.skip_confirmation_notification!
    user.save!
    assert_not user.confirmed?
    assert_nil user.confirmed_at
  end

  test "confirmation_required? returns true when toggle is enabled" do
    user = User.new(name: "Test", email: "toggle_on@example.com", password: "password123")
    user.skip_confirmation_notification!
    user.save!
    assert_equal true, user.confirmation_required?
  end

  test "confirmation_required? returns false when toggle is disabled" do
    Rails.application.config.x.account_email_confirmation_enabled = false
    user = User.new(name: "Test", email: "toggle_off@example.com", password: "password123")
    user.save!
    assert_equal false, user.confirmation_required?
  end

  test "user is active for authentication after confirmation" do
    user = User.new(name: "Test", email: "active_user@example.com", password: "password123")
    user.skip_confirmation_notification!
    user.save!
    user.confirm

    assert user.active_for_authentication?
  end

  test "unconfirmed user is not active for authentication when toggle is enabled" do
    user = User.new(name: "Test", email: "inactive_user@example.com", password: "password123")
    user.skip_confirmation_notification!
    user.save!

    assert_not user.active_for_authentication?
  end

  test "unconfirmed user is active for authentication when toggle is disabled" do
    Rails.application.config.x.account_email_confirmation_enabled = false
    user = User.new(name: "Test", email: "inactive_toggle_off@example.com", password: "password123")
    user.save!

    assert user.active_for_authentication?
  end

  # =========================================================
  # T023 — confirm_within 24h token validity
  # =========================================================
  # T023 — confirm_within 24h token validity (tested via public API)
  # =========================================================

  test "confirmation token is accepted within 24 hours" do
    user = User.new(name: "Test", email: "valid_token@example.com", password: "password123")
    user.skip_confirmation_notification!
    user.save!
    token = user.confirmation_token

    user.update_column(:confirmation_sent_at, 23.hours.ago)

    result = User.confirm_by_token(token)
    assert result.errors.empty?, "Token sent 23h ago should still be valid"
    result.reload
    assert result.confirmed?
  end

  test "confirmation token is rejected after 24 hours" do
    user = User.new(name: "Test", email: "expired_token@example.com", password: "password123")
    user.skip_confirmation_notification!
    user.save!
    token = user.confirmation_token

    user.update_column(:confirmation_sent_at, 25.hours.ago)

    result = User.confirm_by_token(token)
    assert result.errors.any?, "Token sent 25h ago should be expired"
    user.reload
    assert_nil user.confirmed_at
  end

  # =========================================================
  # T055 — Case-insensitive email uniqueness
  # =========================================================

  test "email uniqueness is case-insensitive" do
    user1 = User.new(name: "First", email: "unique@example.com", password: "password123")
    user1.skip_confirmation_notification!
    user1.save!

    user2 = User.new(name: "Second", email: "UNIQUE@EXAMPLE.COM", password: "password123")
    user2.skip_confirmation_notification!

    assert_not user2.valid?
    assert user2.errors[:email].any?
  end

  test "email is downcased on save" do
    user = User.new(name: "Test", email: "MixedCase@Example.COM", password: "password123")
    user.skip_confirmation_notification!
    user.save!

    assert_equal "mixedcase@example.com", user.reload.email
  end
end
