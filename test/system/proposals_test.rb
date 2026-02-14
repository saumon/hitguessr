require "application_system_test_case"

class ProposalsTest < ApplicationSystemTestCase
  def setup
    @organizer = User.create!(email: "organizer@example.com", name: "Organisateur", password: "password123")
    @player1 = User.create!(email: "player1@example.com", name: "Joueur 1", password: "password123")
    @player2 = User.create!(email: "player2@example.com", name: "Joueur 2", password: "password123")

    @team = Team.create!(name: "Les Mélomanes", organizer: @organizer)
    @team.memberships.create!(user: @player1)
    @team.memberships.create!(user: @player2)

    @game = @team.games.create!
  end

  test "player can submit a proposal during collecting phase" do
    sign_in_as @player1

    visit game_path(@game)
    click_link "Soumettre ma musique"

    fill_in "Lien vers la musique", with: "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    click_button "Soumettre ma proposition"

    assert_text "Proposition soumise avec succès"
    assert_text "Ma proposition: Soumise"
  end

  test "player can view their own proposal" do
    proposal = @game.proposals.create!(player: @player1, url: "https://www.youtube.com/watch?v=abc")

    sign_in_as @player1

    visit game_path(@game)
    click_link "Voir ma proposition"

    assert_text "Ma proposition"
    assert_text "youtube.com/watch?v=abc"
  end

  test "proposal is invisible to other players" do
    @game.proposals.create!(player: @player1, url: "https://www.youtube.com/watch?v=abc")

    sign_in_as @player2

    visit game_path(@game)

    # Player2 should see that Player1 has submitted but not the URL
    assert_text "✅"
    assert_text "Joueur 1"
    assert_text "Proposition soumise"

    # But should not see the actual URL
    assert_no_text "youtube.com/watch?v=abc"
  end

  test "player cannot submit proposal twice" do
    @game.proposals.create!(player: @player1, url: "https://www.youtube.com/watch?v=abc")

    sign_in_as @player1

    visit new_game_proposal_path(@game)

    assert_text "Vous avez déjà soumis une proposition"
  end

  test "player cannot submit proposal after collecting phase" do
    @game.proposals.create!(player: @player1, url: "https://www.youtube.com/watch?v=abc")
    @game.proposals.create!(player: @player2, url: "https://www.youtube.com/watch?v=xyz")
    @game.start_guessing!

    sign_in_as @organizer

    visit new_game_proposal_path(@game)

    assert_text "La phase de collecte est terminée"
  end

  test "duplicate URL is rejected" do
    @game.proposals.create!(player: @player1, url: "https://www.youtube.com/watch?v=abc")

    sign_in_as @player2

    visit new_game_proposal_path(@game)

    fill_in "Lien vers la musique", with: "https://www.youtube.com/watch?v=abc"
    click_button "Soumettre ma proposition"

    assert_text "a déjà été proposée"
  end

  test "shows progress bar with submission count" do
    @game.proposals.create!(player: @player1, url: "https://www.youtube.com/watch?v=abc")

    sign_in_as @player2

    visit game_path(@game)

    assert_text "1/3 propositions reçues"
  end
end
