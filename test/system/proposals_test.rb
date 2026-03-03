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

    @game.proposals.create!(player: @player1, url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
    visit game_path(@game)

    assert_text "Ma proposition: Soumise"
  end

  test "player can view their own proposal" do
    proposal = @game.proposals.create!(player: @player1, url: "https://www.youtube.com/watch?v=abc")

    sign_in_as @player1

    visit new_game_proposal_path(@game)

    assert_text "Modifier ma musique"
    assert_field "Lien vers la musique", with: "https://www.youtube.com/watch?v=abc"
  end

  test "proposal is invisible to other players" do
    @game.proposals.create!(player: @player1, url: "https://www.youtube.com/watch?v=abc")

    sign_in_as @player2

    visit game_path(@game)

    # Player2 should see that Player1 has submitted but not the URL
    assert_text "✅"
    assert_text "Joueur 1"
    # But should not see the actual URL
    assert_no_text "youtube.com/watch?v=abc"
  end

  test "player can update their proposal during collecting phase" do
    # Feature 014: visiting new_game_proposal_path when a proposal exists shows the edit form
    @game.proposals.create!(player: @player1, url: "https://www.youtube.com/watch?v=abc")

    sign_in_as @player1

    visit new_game_proposal_path(@game)

    # Should show edit form, not redirect with error
    assert_text "Modifier ma musique"
    assert_no_text "Vous avez déjà soumis une proposition"
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

  # =============================================================
  # T008 [US1] — Modifier une proposition existante en collecte
  # =============================================================

  test "player can edit their existing proposal during collecting phase" do
    sign_in_as @player1

    proposal = @game.proposals.create!(player: @player1, url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")

    # Accès au formulaire d'édition
    visit new_game_proposal_path(@game)
    assert_text "Modifier ma musique"
    assert_field "Lien vers la musique", with: "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

    # Mise à jour
    proposal.update!(url: "https://www.youtube.com/watch?v=9bZkp7q19f0")
    visit new_game_proposal_path(@game)

    assert_field "Lien vers la musique", with: "https://www.youtube.com/watch?v=9bZkp7q19f0"
  end

  test "editing proposal form is pre-filled with existing URL" do
    @game.proposals.create!(player: @player1, url: "https://www.youtube.com/watch?v=prefill")

    sign_in_as @player1

    visit new_game_proposal_path(@game)

    assert_text "Modifier ma musique"
    assert_field "Lien vers la musique", with: "https://www.youtube.com/watch?v=prefill"
  end

  # =============================================================
  # T018 [US2] — Aucune action d'édition disponible en phase guessing
  # =============================================================

  test "no edit action available in guessing phase" do
    @game.proposals.create!(player: @player1, url: "https://www.youtube.com/watch?v=abc")
    @game.proposals.create!(player: @player2, url: "https://www.youtube.com/watch?v=xyz")
    @game.start_guessing!

    sign_in_as @player1

    visit game_path(@game)

    # No edit link visible
    assert_no_text "Modifier ma proposition"
    # Locked state visible
    assert_text "Verrouillée"
  end

  # =============================================================
  # T024 [US3] — Soumettre la même URL en collecte reste accepté
  # =============================================================

  test "submitting the same URL again in collecting phase is accepted" do
    existing_url = "https://www.youtube.com/watch?v=same"
    proposal = @game.proposals.create!(player: @player1, url: existing_url)

    sign_in_as @player1

    proposal.update!(url: existing_url)
    assert_equal existing_url, proposal.reload.url
  end
end
