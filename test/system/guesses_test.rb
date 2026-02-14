require "application_system_test_case"

class GuessesTest < ApplicationSystemTestCase
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
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @game.proposals.create!(player: @player3, url: "https://youtube.com/c")
    @game.start_guessing!
  end

  test "player can submit guesses for all proposals" do
    sign_in_as @player1

    visit game_path(@game)
    click_link "Faire mes devinettes"

    # Player1 should see 2 proposals (not their own)
    assert_text "Proposition #1"
    assert_text "Proposition #2"

    # Select guesses for each proposal
    within(all(".border-gray-200")[0]) do
      choose "Joueur 2"
    end
    within(all(".border-gray-200")[1]) do
      choose "Joueur 3"
    end

    click_button "Soumettre mes devinettes"

    assert_text "Devinettes soumises avec succès"
  end

  test "player cannot submit guesses twice" do
    # Submit guesses for player1
    proposals = @game.proposals.where.not(player: @player1)
    proposals.each do |proposal|
      Guess.create!(player: @player1, proposal: proposal, guessed_author: proposal.player)
    end

    sign_in_as @player1

    visit new_game_guess_path(@game)

    assert_text "Vous avez déjà soumis vos devinettes"
  end

  test "player cannot submit guesses during collecting phase" do
    game2 = @team.games.create!
    game2.proposals.create!(player: @player1, url: "https://youtube.com/d")
    game2.proposals.create!(player: @player2, url: "https://youtube.com/e")
    # Game2 is still in collecting phase

    sign_in_as @player1

    visit new_game_guess_path(game2)

    assert_text "La partie n'est pas en phase de devinettes"
  end

  test "player without proposal cannot submit guesses" do
    # Create a new game where organizer has no proposal
    game2 = @team.games.create!
    game2.proposals.create!(player: @player1, url: "https://youtube.com/d")
    game2.proposals.create!(player: @player2, url: "https://youtube.com/e")
    game2.start_guessing!

    sign_in_as @organizer

    visit new_game_guess_path(game2)

    assert_text "Vous n'avez pas soumis de proposition"
  end

  test "guesses are locked after submission" do
    # Submit guesses
    proposals = @game.proposals.where.not(player: @player1)
    proposals.each do |proposal|
      Guess.create!(player: @player1, proposal: proposal, guessed_author: proposal.player)
    end

    sign_in_as @player1

    visit game_path(@game)

    assert_text "Mes devinettes: Soumises"
    # No link to modify guesses
    assert_no_link "Modifier mes devinettes"
  end

  test "own proposal is not shown in guessing form" do
    sign_in_as @player1

    visit new_game_guess_path(@game)

    # Player1's URL should not appear
    assert_no_text "youtube.com/a"
    # But other URLs should appear
    assert_text "youtube.com/b"
    assert_text "youtube.com/c"
  end
end
