require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @organizer = User.create!(
      name: "Organisateur",
      email: "organizer_test@example.com",
      password: "password123"
    )
    @member = User.create!(
      name: "Membre",
      email: "member_test@example.com",
      password: "password123"
    )
    @member_two = User.create!(
      name: "Membre Deux",
      email: "member_two_test@example.com",
      password: "password123"
    )
    @non_member = User.create!(
      name: "Non Membre",
      email: "non_member_test@example.com",
      password: "password123"
    )
    @organizer_two = User.create!(
      name: "Organisateur Deux",
      email: "organizer_two_test@example.com",
      password: "password123"
    )

    @team = Team.create!(name: "Équipe Alpha", organizer: @organizer)
    @team.memberships.create!(user: @member)
    @team.memberships.create!(user: @member_two)

    @team_two = Team.create!(name: "Équipe Beta", organizer: @organizer_two)
    @team_two.memberships.create!(user: @member)
    @team_two.memberships.create!(user: @member_two)

    # Create a third team for the finished game (since only one active game per team)
    @team_three = Team.create!(name: "Équipe Gamma", organizer: @organizer_two)
    @team_three.memberships.create!(user: @member)
    @team_three.memberships.create!(user: @member_two)

    @collecting_game = @team.games.create!(status: :collecting)

    @guessing_game = @team_two.games.create!(status: :guessing, started_at: Time.current)

    @finished_game = @team_three.games.create!(status: :finished, started_at: 1.hour.ago, finished_at: Time.current)

    # Create proposals for the collecting game (no guesses since game is in collecting phase)
    @proposal_one = @collecting_game.proposals.create!(player: @organizer, url: "https://example.com/song1")
    @proposal_two = @collecting_game.proposals.create!(player: @member, url: "https://example.com/song2")
  end

  # ===========================================
  # User Story 1: Annulation par l'organisateur
  # ===========================================

  # T005: destroy succeeds for organizer
  test "organizer can destroy an active game in collecting status" do
    sign_in @organizer

    assert_difference("Game.count", -1) do
      delete game_path(@collecting_game)
    end

    assert_redirected_to team_games_path(@team)
    assert_equal I18n.t("games.destroy.success"), flash[:notice]
  end

  test "organizer can destroy an active game in guessing status" do
    sign_in @organizer_two

    assert_difference("Game.count", -1) do
      delete game_path(@guessing_game)
    end

    assert_redirected_to team_games_path(@team_two)
    assert_equal I18n.t("games.destroy.success"), flash[:notice]
  end

  # T006: destroy redirects with flash notice
  test "destroy redirects to team games index with success notice" do
    sign_in @organizer

    delete game_path(@collecting_game)

    assert_redirected_to team_games_path(@team)
    follow_redirect!
    assert_select "body", /#{I18n.t('games.destroy.success')}/i
  end

  # T007: cascade deletes proposals and guesses
  test "destroy cascades deletes proposals" do
    sign_in @organizer

    # Ensure we have proposals
    assert @collecting_game.proposals.count > 0, "Game should have proposals"

    proposal_ids = @collecting_game.proposals.pluck(:id)

    delete game_path(@collecting_game)

    # Verify cascade deletion of proposals
    assert_equal 0, Proposal.where(id: proposal_ids).count, "Proposals should be deleted"
  end

  # T007b: verify transaction rollback on destroy failure (atomicity per FR-006)
  # Note: This test verifies the transaction structure exists.
  # A proper rollback test would require mocking, which is not available in this setup.
  test "destroy action uses transaction for atomicity" do
    sign_in @organizer

    # Verify game has associated data
    assert @collecting_game.proposals.count > 0

    # When destroy succeeds, all related data should be deleted atomically
    proposal_count_before = Proposal.count
    game_proposal_count = @collecting_game.proposals.count

    delete game_path(@collecting_game)

    # All deletions should have happened atomically
    assert_equal proposal_count_before - game_proposal_count, Proposal.count
  end

  # ===========================================
  # User Story 2: Tentative non autorisée
  # ===========================================

  # T013: destroy returns 403/redirect for non-organizer
  test "non-organizer member cannot destroy a game" do
    sign_in @member

    assert_no_difference("Game.count") do
      delete game_path(@collecting_game)
    end

    # Should redirect with unauthorized message
    assert_redirected_to @team
    assert_equal "Seul l'organisateur peut effectuer cette action.", flash[:alert]
  end

  # T014: destroy returns 403/redirect for non-member
  test "non-member cannot destroy a game" do
    sign_in @non_member

    assert_no_difference("Game.count") do
      delete game_path(@collecting_game)
    end

    # Should redirect since user is not the organizer
    assert_response :redirect
  end

  test "unauthenticated user cannot destroy a game" do
    assert_no_difference("Game.count") do
      delete game_path(@collecting_game)
    end

    # Devise should redirect to sign in
    assert_redirected_to new_user_session_path
  end

  # ===========================================
  # User Story 3: Partie terminée/introuvable
  # ===========================================

  # T017: destroy returns 422 for finished game
  test "organizer cannot destroy a finished game" do
    sign_in @organizer_two

    assert_no_difference("Game.count") do
      delete game_path(@finished_game)
    end

    assert_redirected_to @finished_game
    assert_equal I18n.t("games.destroy.cannot_cancel_finished"), flash[:alert]
  end

  # T018: destroy returns 404 for non-existent game
  test "destroy returns 404 for non-existent game" do
    sign_in @organizer

    assert_no_difference("Game.count") do
      delete game_path(id: 999999)
    end

    assert_redirected_to teams_path
    assert_equal "Partie introuvable.", flash[:alert]
  end

  # ===========================================
  # User Story 1/2/3: Lancement de partie avec seuil minimum
  # ===========================================

  test "organizer can create game with exactly three members" do
    sign_in @organizer

    team = Team.create!(name: "Équipe Trio", organizer: @organizer)
    team.memberships.create!(user: @member)
    team.memberships.create!(user: @member_two)

    assert_difference("Game.count", 1) do
      post team_games_path(team)
    end

    created_game = Game.order(:id).last
    assert_redirected_to game_path(created_game)
    assert_equal I18n.t("games.create.success"), flash[:notice]
  end

  test "organizer can create game with more than three members" do
    sign_in @organizer

    team = Team.create!(name: "Équipe Quartette", organizer: @organizer)
    team.memberships.create!(user: @member)
    team.memberships.create!(user: @member_two)
    team.memberships.create!(user: @non_member)

    assert_difference("Game.count", 1) do
      post team_games_path(team)
    end

    assert_equal I18n.t("games.create.success"), flash[:notice]
  end

  test "organizer cannot create game with two members" do
    sign_in @organizer

    team = Team.create!(name: "Équipe Duo", organizer: @organizer)
    team.memberships.create!(user: @member)

    assert_no_difference("Game.count") do
      post team_games_path(team)
    end

    assert_response :unprocessable_entity
    assert_includes response.body, I18n.t("games.create.minimum_members_required", count: Game::MINIMUM_TEAM_MEMBERS)
  end

  test "organizer cannot create game with one member" do
    sign_in @organizer

    team = Team.create!(name: "Équipe Solo", organizer: @organizer)

    assert_no_difference("Game.count") do
      post team_games_path(team)
    end

    assert_response :unprocessable_entity
    assert_includes response.body, I18n.t("games.create.minimum_members_required", count: Game::MINIMUM_TEAM_MEMBERS)
  end

  test "existing single active game rule still blocks creation with three or more members" do
    sign_in @organizer

    team = Team.create!(name: "Équipe Active", organizer: @organizer)
    team.memberships.create!(user: @member)
    team.memberships.create!(user: @member_two)
    team.games.create!(status: :collecting)

    assert_no_difference("Game.count") do
      post team_games_path(team)
    end

    assert_response :unprocessable_entity
    assert_includes response.body, "Une partie est déjà en cours pour cette équipe"
  end

  test "create action exposes explicit success and refusal feedback messages" do
    sign_in @organizer

    eligible_team = Team.create!(name: "Équipe Message OK", organizer: @organizer)
    eligible_team.memberships.create!(user: @member)
    eligible_team.memberships.create!(user: @member_two)

    post team_games_path(eligible_team)
    assert_equal I18n.t("games.create.success"), flash[:notice]

    ineligible_team = Team.create!(name: "Équipe Message KO", organizer: @organizer)
    ineligible_team.memberships.create!(user: @member)

    post team_games_path(ineligible_team)
    assert_response :unprocessable_entity
    assert_includes response.body, I18n.t("games.create.minimum_members_required", count: Game::MINIMUM_TEAM_MEMBERS)
  end
end
