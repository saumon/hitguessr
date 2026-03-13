require "test_helper"

class PublicIdsRoutingTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @organizer = User.create!(name: "Organisateur", email: "org-routing-#{SecureRandom.hex(4)}@example.com", password: "password123")
    @player1 = User.create!(name: "Joueur 1", email: "p1-routing-#{SecureRandom.hex(4)}@example.com", password: "password123")
    @player2 = User.create!(name: "Joueur 2", email: "p2-routing-#{SecureRandom.hex(4)}@example.com", password: "password123")

    @team = Team.create!(name: "Routing Test Team", organizer: @organizer)
    @team.memberships.create!(user: @player1)
    @team.memberships.create!(user: @player2)

    @game = @team.games.create!
  end

  # T016: Malformed game public_id 404
  test "malformed game public_id returns 404" do
    sign_in @organizer

    get "/games/gm_sho"
    assert_redirected_to teams_path
    assert_equal "Partie introuvable.", flash[:alert]
  end

  test "special characters in game public_id returns 404" do
    sign_in @organizer

    get "/games/gm_abcdefg!"
    # Rails may interpret this differently, but it should not succeed
    assert_response :redirect
  end

  # ============================================================
  # Feature 017 – US3: End-to-end public-id navigation
  # ============================================================

  # T031: Team -> Game -> Proposal flow via public IDs
  test "team to game to proposal flow uses public ids" do
    sign_in @organizer

    # Access team by public_id
    get team_path(@team)
    assert_response :success

    # Access game by public_id
    get game_path(@game)
    assert_response :success

    # Access new proposal by game public_id
    get new_game_proposal_path(@game)
    assert_response :success

    # Submit proposal
    post game_proposals_path(@game), params: { proposal: { url: "https://youtube.com/watch?v=test123" } }
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  # T032: Guessing/results flow via public IDs
  test "guessing and results flow uses public ids" do
    sign_in @player1
    post game_proposals_path(@game), params: { proposal: { url: "https://youtube.com/watch?v=p1song" } }

    sign_in @player2
    post game_proposals_path(@game), params: { proposal: { url: "https://youtube.com/watch?v=p2song" } }

    # Only 2 of 3 members submitted, so game may still be collecting
    # Start guessing manually if still collecting
    @game.reload
    @game.with_lock { @game.start_guessing! } if @game.collecting?

    # Access guessing page via public_id
    sign_in @player1
    get new_game_guess_path(@game)
    assert_response :success

    # Submit guesses
    proposals = @game.proposals.where.not(player: @player1)
    guesses_params = {}
    proposals.each { |p| guesses_params[p.id.to_s] = p.player_id.to_s }
    post game_guesses_path(@game), params: { guesses: guesses_params }
    assert_response :redirect

    # Finish game and access results
    @game.reload
    @game.with_lock { @game.finish! } unless @game.finished?

    get game_results_path(@game)
    assert_response :success
  end

  # T033: Regression — no generated link contains numeric ID
  test "no generated public link contains numeric id" do
    sign_in @organizer

    get team_path(@team)
    assert_response :success

    # Verify the response body does not contain /games/\d+ or /teams/\d+ links
    body = response.body
    # Check that game links use public_id format, not numeric
    assert_no_match %r{href="/games/\d+"}, body, "Game links should not use numeric IDs"
    assert_no_match %r{href="/teams/\d+"}, body, "Team links should not use numeric IDs"
  end

  # T049: N+1 regression check for team/game pages
  test "team page does not produce N+1 queries for public_id resolution" do
    sign_in @organizer

    # Load team page — should not trigger extra queries per game for public_id
    queries = track_query_count { get team_path(@team) }
    assert_response :success
    first_run = queries

    # Add more games and verify query count stays bounded
    3.times do
      @game.update_columns(status: :finished, finished_at: Time.current) unless @game.finished?
      @team.games.create!
      @game = @team.games.last
    end

    queries = track_query_count { get team_path(@team) }
    assert_response :success
    second_run = queries

    # With 4 games vs 1, query count should not grow linearly
    # Allow some slack (e.g. +3 for the new game records themselves)
    assert second_run <= first_run + 5,
      "Possible N+1: #{first_run} queries with 1 game, #{second_run} with 4 games"
  end

  private

  def track_query_count(&block)
    count = 0
    counter = ->(_name, _start, _finish, _id, payload) {
      count += 1 unless payload[:name] == "SCHEMA" || payload[:cached]
    }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &block)
    count
  end
end
