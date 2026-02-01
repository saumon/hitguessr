require "application_system_test_case"

class SingleActiveGameTest < ApplicationSystemTestCase
  def setup
    @organizer = User.create!(email: "organizer@example.com", name: "Organisateur", password: "password123")
    @player1 = User.create!(email: "player1@example.com", name: "Joueur 1", password: "password123")
    @player2 = User.create!(email: "player2@example.com", name: "Joueur 2", password: "password123")

    @team = Team.create!(name: "Les Mélomanes", organizer: @organizer)
    @team.memberships.create!(user: @player1)
    @team.memberships.create!(user: @player2)
  end

  # US2: Bouton désactivé avec tooltip si partie active
  test "organizer sees disabled button with tooltip when game is active" do
    # Create an active game
    @team.games.create!

    sign_in_as @organizer
    visit team_path(@team)

    # Button should be disabled (has opacity-50 and cursor-not-allowed classes)
    assert_selector "span.opacity-50.cursor-not-allowed", text: "🎮 Lancer une partie"

    # Tooltip should be present
    assert_selector "span", text: "Une partie est déjà en cours", visible: :all
  end

  # US2: Indicateur de partie en cours
  test "organizer sees active game indicator" do
    game = @team.games.create!

    sign_in_as @organizer
    visit team_path(@team)

    # Should see the active game indicator
    assert_text "Partie en cours:"
    assert_selector "a", text: "Partie ##{game.id}"
  end

  # US3: Bouton actif après fin de partie
  test "organizer sees enabled button after game is finished" do
    game = @team.games.create!
    game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    game.start_guessing!
    game.finish!
    @team.reload # Ensure team association cache is cleared

    sign_in_as @organizer
    visit team_path(@team)

    # Button should be enabled (a link, not a span)
    assert_selector "a", text: "🎮 Lancer une partie"
    assert_no_selector "span.opacity-50", text: "🎮 Lancer une partie"
  end

  # US3: Création réussie après fin de partie
  test "organizer can create new game after previous game is finished" do
    game = @team.games.create!
    game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    game.start_guessing!
    game.finish!

    sign_in_as @organizer
    visit team_path(@team)

    # Click the button to create a new game
    click_link "🎮 Lancer une partie"

    # Should be on new game page or game created
    assert_current_path new_team_game_path(@team)
  end

  # US1: Bouton actif quand aucune partie active
  test "organizer sees enabled button when no active game exists" do
    sign_in_as @organizer
    visit team_path(@team)

    # Button should be enabled
    assert_selector "a", text: "🎮 Lancer une partie"
  end
end
