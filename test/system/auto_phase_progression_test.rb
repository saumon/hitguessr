require "application_system_test_case"

class AutoPhaseProgressionTest < ApplicationSystemTestCase
  def setup
    @organizer = User.create!(email: "organizer@example.com", name: "Organisateur", password: "password123")
    @player1 = User.create!(email: "player1@example.com", name: "Joueur 1", password: "password123")
    @player2 = User.create!(email: "player2@example.com", name: "Joueur 2", password: "password123")

    @team = Team.create!(name: "Les Mélomanes", organizer: @organizer)
    @team.memberships.create!(user: @player1)
    @team.memberships.create!(user: @player2)

    @game = @team.games.create!
  end

  # ============================
  # US1: Auto Progress to Guessing
  # ============================

  test "game automatically progresses to guessing when last proposal submitted" do
    # Players 1 and 2 submit proposals first
    # Disable callback to avoid any side effects during setup
    Proposal.skip_callback(:commit, :after, :try_auto_progress_game)
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    Proposal.set_callback(:commit, :after, :try_auto_progress_game)

    # Verify game is still in collecting phase (organizer hasn't submitted)
    @game.reload
    assert @game.collecting?, "Game should still be collecting"
    assert_equal 2, @game.proposals.count, "Should have 2 proposals at this point"

    # Organizer logs in and submits the last proposal
    sign_in_as @organizer

    # Verify login succeeded
    assert_text "Bonjour, Organisateur"

    visit game_path(@game)

    # Debug: check page state
    assert_text "Collecte des propositions"

    click_link "Soumettre ma musique", match: :first

    fill_in "Lien vers la musique", with: "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    click_button "Soumettre ma proposition"

    # Verify proposal was submitted
    assert_text "Proposition soumise avec succès"

    # Check proposal count before reload
    assert_equal 3, @game.proposals.reload.count, "Should have 3 proposals after submission"

    # Game should automatically progress to guessing phase
    @game.reload
    assert @game.guessing?, "Game should have auto-progressed to guessing phase"

    # UI should reflect the new phase
    assert_text "PHASE: Devinettes"
  end

  test "game does not auto-progress when not all proposals submitted" do
    # Only 1 player submits
    sign_in_as @player1

    visit game_path(@game)
    click_link "🎵 Soumettre ma musique"

    fill_in "Lien vers la musique", with: "https://www.youtube.com/watch?v=abc123"
    click_button "Soumettre ma proposition"

    # Verify proposal was submitted
    assert_text "Proposition soumise avec succès"

    # Game should still be in collecting phase
    @game.reload
    assert @game.collecting?, "Game should still be collecting"

    # UI should show waiting for more proposals
    assert_text "1/3 propositions reçues"
  end

  # ============================
  # US2: Auto Finish Game
  # ============================

  test "game automatically finishes when last guess submitted" do
    # Setup: Create proposals - skip callback to control when guessing starts
    Proposal.skip_callback(:commit, :after, :try_auto_progress_game)
    @game.proposals.create!(player: @organizer, url: "https://youtube.com/org")
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    Proposal.set_callback(:commit, :after, :try_auto_progress_game)
    @game.start_guessing!

    @game.reload
    assert @game.guessing?, "Game should be in guessing phase after start_guessing!"

    # Organizer and Player1 submit guesses programmatically
    # Skip callback to avoid auto-finishing early
    Guess.skip_callback(:commit, :after, :try_auto_finish_game)

    proposals_for_organizer = @game.proposals.where.not(player: @organizer)
    proposals_for_organizer.each do |proposal|
      Guess.create!(player: @organizer, proposal: proposal, guessed_author: proposal.player)
    end

    proposals_for_player1 = @game.proposals.where.not(player: @player1)
    proposals_for_player1.each do |proposal|
      Guess.create!(player: @player1, proposal: proposal, guessed_author: proposal.player)
    end
    Guess.set_callback(:commit, :after, :try_auto_finish_game)

    # Verify game is still in guessing phase
    @game.reload
    assert @game.guessing?, "Game should still be in guessing phase"

    # Player2 logs in and submits the last guesses via UI
    sign_in_as @player2
    assert_text "Bonjour, Joueur 2"

    visit game_path(@game)
    assert_text "PHASE: Devinettes"

    click_link "Faire mes devinettes", match: :first

    # Player2 should see 2 proposals (from organizer and player1)
    # Get proposal IDs by reading the radio button names
    proposal_ids = @game.proposals.where.not(player: @player2).pluck(:id)

    # Select a guess for each proposal by clicking the radio button directly
    proposal_ids.each do |pid|
      first("input[name='guesses[#{pid}]']").click
    end

    click_button "Soumettre mes devinettes"

    # Verify the submission message
    assert_text "Devinettes soumises avec succès"

    # Game should automatically finish
    @game.reload
    assert @game.finished?, "Game should have auto-finished"

    # UI should show finished state
    assert_text "PARTIE TERMINÉE"
  end

  test "game does not auto-finish when not all guesses submitted" do
    # Setup: Create proposals - skip callback to control when guessing starts
    Proposal.skip_callback(:commit, :after, :try_auto_progress_game)
    @game.proposals.create!(player: @organizer, url: "https://youtube.com/org")
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    Proposal.set_callback(:commit, :after, :try_auto_progress_game)
    @game.start_guessing!

    # Only player1 submits guesses via UI
    sign_in_as @player1
    assert_text "Bonjour, Joueur 1"

    visit game_path(@game)
    assert_text "PHASE: Devinettes"

    # Navigate directly to the guesses form
    visit new_game_guess_path(@game)

    # Wait for the form to load
    assert_text "Pour chaque musique proposée"

    # Get all unique proposal IDs from the radio button names on the page
    # The radio buttons have names like "guesses[123]"
    all_radios = all("input[type='radio']")
    proposal_ids = all_radios.map { |r| r["name"] }.uniq

    # Select a guess for each proposal group
    proposal_ids.each do |name|
      first("input[name='#{name}']").click
    end

    click_button "Soumettre mes devinettes"

    assert_text "Devinettes soumises avec succès"

    # Game should still be in guessing phase
    @game.reload
    assert @game.guessing?, "Game should still be in guessing phase"
  end
end
