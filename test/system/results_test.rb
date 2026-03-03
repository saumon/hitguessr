require "application_system_test_case"

class ResultsTest < ApplicationSystemTestCase
  def setup
    @organizer = User.create!(email: "organizer@example.com", name: "Organisateur", password: "password123")
    @player1 = User.create!(email: "player1@example.com", name: "Joueur 1", password: "password123")
    @player2 = User.create!(email: "player2@example.com", name: "Joueur 2", password: "password123")
    @player3 = User.create!(email: "player3@example.com", name: "Joueur 3", password: "password123")

    @team = Team.create!(name: "Les Mélomanes", organizer: @organizer)
    @team.memberships.create!(user: @player1)
    @team.memberships.create!(user: @player2)
    @team.memberships.create!(user: @player3)

    @game = @team.games.create!
    @proposal1 = @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @proposal2 = @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @proposal3 = @game.proposals.create!(player: @player3, url: "https://youtube.com/c")
    @game.start_guessing!

    # Player1 guesses: 2 correct
    Guess.create!(player: @player1, proposal: @proposal2, guessed_author: @player2)  # Correct
    Guess.create!(player: @player1, proposal: @proposal3, guessed_author: @player3)  # Correct

    # Player2 guesses: 1 correct
    Guess.create!(player: @player2, proposal: @proposal1, guessed_author: @player1)  # Correct
    Guess.create!(player: @player2, proposal: @proposal3, guessed_author: @player1)  # Wrong

    # Player3 guesses: 0 correct
    Guess.create!(player: @player3, proposal: @proposal1, guessed_author: @player2)  # Wrong
    Guess.create!(player: @player3, proposal: @proposal2, guessed_author: @player1)  # Wrong

    @game.reload
  end

  test "shows ranking with medals" do
    sign_in_as @player1

    visit game_results_path(@game)

    assert_text "🏆 Résultats"
    assert_text "Classement"

    # Check medals
    assert_text "🥇"
    assert_text "🥈"
    assert_text "🥉"
  end

  test "shows correct scores" do
    sign_in_as @player1

    visit game_results_path(@game)

    ranking_items = all("div[class*='rounded-lg']").map(&:text)
    first_player_row = ranking_items.find { |text| text.include?("Joueur 1") }
    assert_includes first_player_row, "2"
  end

  test "shows detailed results for each proposal" do
    sign_in_as @player1

    visit game_results_path(@game)

    assert_text "Détail des propositions"
    assert_text "Proposition #1"
    assert_text "Par: Joueur 1"
    assert_text "youtube.com/a"
  end

  test "shows correct/incorrect indicators for guesses" do
    sign_in_as @player1

    visit game_results_path(@game)

    # Check for correct (✅) and incorrect (❌) markers
    assert_text "✅"
    assert_text "❌"
  end

  test "highlights current user in ranking" do
    sign_in_as @player1

    visit game_results_path(@game)

    assert_text "(vous)"
  end

  test "cannot access results before game is finished" do
    game2 = @team.games.create!
    game2.proposals.create!(player: @player1, url: "https://youtube.com/d")
    game2.proposals.create!(player: @player2, url: "https://youtube.com/e")
    game2.start_guessing!
    # Game2 is in guessing phase, not finished

    sign_in_as @player1

    visit game_results_path(game2)

    assert_text "La partie n'est pas encore terminée"
  end

  test "non-team-member cannot access results" do
    outsider = User.create!(email: "outsider@example.com", name: "Outsider", password: "password123")

    sign_in_as outsider

    visit game_results_path(@game)

    assert_text "Vous n'êtes pas membre"
  end

  test "full game cycle shows correct final ranking" do
    sign_in_as @player1

    visit game_results_path(@game)

    # Verify ranking order
    ranking_items = all("div[class*='rounded-lg']").select { |node| node.text.include?("Joueur") }

    # First should be Player1 (2 pts)
    assert_match(/Joueur 1/, ranking_items[0].text)

    # Second should be Player2 (1 pt)
    assert_match(/Joueur 2/, ranking_items[1].text)

    # Third should be Player3 (0 pts)
    assert_match(/Joueur 3/, ranking_items[2].text)
  end
end
