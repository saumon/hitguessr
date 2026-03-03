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

    # Organizer submits the last proposal
    @game.proposals.create!(player: @organizer, url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")

    # Verify proposal was submitted
    assert @game.proposals.where(player: @organizer).exists?

    # Check proposal count before reload
    assert_equal 3, @game.proposals.reload.count, "Should have 3 proposals after submission"

    # Game should automatically progress to guessing phase
    @game.reload
    assert @game.guessing?, "Game should have auto-progressed to guessing phase"
  end

  test "game does not auto-progress when not all proposals submitted" do
    # Only 1 player submits
    @game.proposals.create!(player: @player1, url: "https://www.youtube.com/watch?v=abc123")

    # Verify proposal was submitted
    assert @game.proposals.where(player: @player1).exists?

    # Game should still be in collecting phase
    @game.reload
    assert @game.collecting?, "Game should still be collecting"
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

    # Player2 submits the final guesses (programmatic, deterministic)
    proposals_for_player2 = @game.proposals.where.not(player: @player2)
    proposals_for_player2.each do |proposal|
      Guess.create!(player: @player2, proposal: proposal, guessed_author: proposal.player)
    end

    # Game should automatically finish
    @game.reload
    assert @game.finished?, "Game should have auto-finished"
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

    visit game_path(@game)
    assert_text "PHASE: Devinettes"

    # Navigate directly to the guesses form
    visit new_game_guess_path(@game)

    # Wait for the form to load
    assert_text "Pour chaque musique proposée"

    # Get all unique proposal IDs from the radio button names on the page
    # The radio buttons have names like "guesses[123]"
    all_radios = all("input[type='radio']", minimum: 1)
    proposal_ids = all_radios.map { |r| r["name"] }.uniq

    # Select a guess for each proposal group
    proposal_ids.each do |name|
      first("input[name='#{name}']").click
    end

    click_button "Soumettre mes devinettes"

    if page.has_button?("Confirmer quand même")
      click_button "Confirmer quand même"
    end

    # Game should still be in guessing phase
    @game.reload
    assert @game.guessing?, "Game should still be in guessing phase"
  end
end
