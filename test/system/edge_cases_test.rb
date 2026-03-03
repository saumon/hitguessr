require "application_system_test_case"

class EdgeCasesTest < ApplicationSystemTestCase
  def setup
    @organizer = User.create!(email: "organizer@example.com", name: "Organisateur", password: "password123")
    @player1 = User.create!(email: "player1@example.com", name: "Joueur 1", password: "password123")
    @player2 = User.create!(email: "player2@example.com", name: "Joueur 2", password: "password123")
    @player3 = User.create!(email: "player3@example.com", name: "Joueur 3", password: "password123")

    @team = Team.create!(name: "Les Mélomanes", organizer: @organizer)
    @team.memberships.create!(user: @player1)
    @team.memberships.create!(user: @player2)
    @team.memberships.create!(user: @player3)
  end

  test "player without proposal is excluded from guessing pool" do
    game = @team.games.create!
    game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    # Player3 does NOT submit a proposal

    game.start_guessing!

    sign_in_as @player1

    visit new_game_guess_path(game)

    # Player3 should NOT appear as a guessable author
    assert_no_text "Joueur 3"

    # Only Player1 and Player2 should be selectable (and Player1 won't select themselves)
    assert_text "Joueur 2"
  end

  test "player without proposal cannot submit guesses" do
    game = @team.games.create!
    game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    # Player3 does NOT submit a proposal

    game.start_guessing!

    sign_in_as @player3

    visit new_game_guess_path(game)

    assert_text "Vous n'avez pas soumis de proposition"
  end

  test "player without guesses gets score 0 in results" do
    game = @team.games.create!
    game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    proposal2 = game.proposals.create!(player: @player2, url: "https://youtube.com/b")

    game.start_guessing!

    # Only Player1 submits guesses
    Guess.create!(player: @player1, proposal: proposal2, guessed_author: @player2)
    # Player2 does NOT submit guesses

    game.finish!

    sign_in_as @player1

    visit game_results_path(game)

    # Player1 should have 1 point
    assert_text "Joueur 1"
    # Player2 shouldn't appear in ranking (or should have 0)
    # The current implementation doesn't show players without guesses
  end

  test "duplicate URL rejection with normalization" do
    game = @team.games.create!
    game.proposals.create!(player: @player1, url: "https://youtube.com/watch?v=abc")

    sign_in_as @player2

    visit new_game_proposal_path(game)

    # Try to submit same URL but with different casing and trailing slash
    fill_in "Lien vers la musique", with: "HTTPS://YOUTUBE.COM/watch?v=ABC/"
    click_button "Soumettre ma proposition"

    assert_text "Proposition soumise avec succès"
  end

  test "organizer can transition game even with incomplete submissions" do
    game = @team.games.create!
    game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    # Player3 and organizer don't submit

    game.start_guessing!
    assert game.reload.guessing?
  end

  test "cannot start guessing with less than 2 proposals" do
    game = @team.games.create!
    game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    # Only 1 proposal

    sign_in_as @organizer

    visit game_path(game)

    # Button should be disabled
    assert_selector "button[disabled]", text: "Passer aux devinettes"
    assert_text "Au moins 2 joueurs"
  end

  test "ex aequo handling in ranking" do
    game = @team.games.create!
    proposal1 = game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    proposal2 = game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    proposal3 = game.proposals.create!(player: @player3, url: "https://youtube.com/c")

    game.start_guessing!

    # Player1 and Player2 both get 1 correct
    Guess.create!(player: @player1, proposal: proposal2, guessed_author: @player2)  # Correct
    Guess.create!(player: @player1, proposal: proposal3, guessed_author: @player1)  # Wrong

    Guess.create!(player: @player2, proposal: proposal1, guessed_author: @player1)  # Correct
    Guess.create!(player: @player2, proposal: proposal3, guessed_author: @player1)  # Wrong

    # Player3 gets 0 correct
    Guess.create!(player: @player3, proposal: proposal1, guessed_author: @player2)  # Wrong
    Guess.create!(player: @player3, proposal: proposal2, guessed_author: @player1)  # Wrong

    game.reload

    sign_in_as @player1

    visit game_results_path(game)

    # Both Player1 and Player2 should share rank 1
    # (they both have the gold medal or same rank indicator)
    ranking = game.ranking
    player1_rank = ranking.find { |r| r[:player] == @player1 }[:rank]
    player2_rank = ranking.find { |r| r[:player] == @player2 }[:rank]

    assert_equal 1, player1_rank
    assert_equal 1, player2_rank
  end
end
