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

  private

  def create_secondary_team_and_game
    other_team = Team.create!(name: "Les Rockeurs", organizer: @organizer)
    other_team.memberships.create!(user: @player1)
    other_team.memberships.create!(user: @player2)
    other_team.memberships.create!(user: @player3)
    other_team.games.create!
  end

  public

  test "player can submit guesses for all proposals" do
    sign_in_as @player1

    visit new_game_guess_path(@game)

    # Player1 should see 2 proposals (not their own)
    assert_text "Proposition #1"
    assert_text "Proposition #2"

    # Select one guess for each proposal group
    proposal_names = all("input[type='radio']", minimum: 1).map { |radio| radio[:name] }.uniq
    proposal_names.each do |name|
      first("input[name='#{name}']", minimum: 1).click
    end

    click_button "Soumettre mes devinettes"

    if page.has_button?("Confirmer quand même")
      click_button "Confirmer quand même"
    end
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
    game2 = create_secondary_team_and_game
    game2.proposals.create!(player: @player1, url: "https://youtube.com/d")
    game2.proposals.create!(player: @player2, url: "https://youtube.com/e")
    # Game2 is still in collecting phase

    sign_in_as @player1

    visit new_game_guess_path(game2)

    assert_text "La partie n'est pas en phase de devinettes"
  end

  test "player without proposal cannot submit guesses" do
    # Create a new game where organizer has no proposal
    game2 = create_secondary_team_and_game
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

  test "displays player guess status table during guessing phase" do
    sign_in_as @player1

    visit game_path(@game)

    # Should see the player status section
    assert_selector "h3", text: "Statut des joueurs:"

    # Should see all players in the pool
    assert_text "Joueur 1"
    assert_text "Joueur 2"
    assert_text "Joueur 3"

    # All should be "En attente" initially
    assert_selector "span", text: "⏳", count: 3
  end

  test "player status updates after submitting guesses" do
    # Player1 submits all guesses
    proposals = @game.proposals.where.not(player: @player1)
    proposals.each do |proposal|
      Guess.create!(player: @player1, proposal: proposal, guessed_author: proposal.player)
    end

    sign_in_as @player2

    visit game_path(@game)

    # Should see the status table
    assert_selector "h3", text: "Statut des joueurs:"

    # Player1 should show as submitted (✅), others as waiting (⏳)
    assert_selector "span", text: "✅", minimum: 1
    assert_selector "span", text: "⏳", minimum: 2
  end
end
