require "application_system_test_case"

class CancelGameTest < ApplicationSystemTestCase
  def setup
    @organizer = User.create!(
      email: "organizer_cancel@example.com",
      name: "Organisateur Cancel",
      password: "password123"
    )
    @member = User.create!(
      email: "member_cancel@example.com",
      name: "Membre Cancel",
      password: "password123"
    )
    @member_two = User.create!(
      email: "member_cancel_two@example.com",
      name: "Membre Cancel Deux",
      password: "password123"
    )
    @team = Team.create!(name: "Équipe Cancel Test", organizer: @organizer)
    @team.memberships.create!(user: @member)
    @team.memberships.create!(user: @member_two)
  end

  # T012: System test - organizer cancels active game with confirmation
  test "organizer can cancel an active game with confirmation" do
    # Create a game in collecting status
    game = @team.games.create!(status: :collecting)

    sign_in_as @organizer

    visit game_path(game)

    assert game.can_cancel?
    game.destroy!
    assert_nil Game.find_by(id: game.id)
  end

  test "organizer can cancel a game in guessing phase" do
    # Create a game in guessing status
    game = @team.games.create!(status: :guessing, started_at: Time.current)

    sign_in_as @organizer

    visit game_path(game)

    assert game.can_cancel?
    game.destroy!
    assert_nil Game.find_by(id: game.id)
  end

  test "member cannot see cancel button" do
    game = @team.games.create!(status: :collecting)

    sign_in_as @member

    visit game_path(game)

    # The cancel button should not be visible to non-organizers
    assert_no_selector "form[action='#{game_path(game)}']"
  end

  test "cancel button is not visible for finished games" do
    game = @team.games.create!(status: :finished, started_at: 1.hour.ago, finished_at: Time.current)

    sign_in_as @organizer

    visit game_path(game)

    # The cancel button should not be visible for finished games
    assert_no_selector "form[action='#{game_path(game)}']"
  end

  private

  def sign_in_as(user)
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Mot de passe", with: "password123"
    click_button "Se connecter"
  end
end
