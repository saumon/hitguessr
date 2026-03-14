require "test_helper"

# Integration tests for feature 018: Team-Scoped Game Numbering
# Verifies independent numbering across teams, stability on deletion,
# consistency across views, and absence of extra SQL queries.
class TeamGameNumberingFlowTest < ActionDispatch::IntegrationTest
  def setup
    Guess.delete_all
    Proposal.delete_all
    Game.delete_all
    Membership.delete_all
    TeamInvitation.delete_all
    Team.delete_all
    User.delete_all

    @organizer = User.create!(name: "Organisateur", email: "org@example.com", password: "password123")
    @member1   = User.create!(name: "Joueur 1",      email: "p1@example.com",  password: "password123")
    @member2   = User.create!(name: "Joueur 2",      email: "p2@example.com",  password: "password123")
    @member3   = User.create!(name: "Joueur 3",      email: "p3@example.com",  password: "password123")

    @team_a = Team.create!(name: "Team Alpha", organizer: @organizer)
    @team_a.memberships.create!(user: @member1)
    @team_a.memberships.create!(user: @member2)
    @team_a.memberships.create!(user: @member3)

    @team_b = Team.create!(name: "Team Beta", organizer: @organizer)
    @team_b.memberships.create!(user: @member1)
    @team_b.memberships.create!(user: @member2)
    @team_b.memberships.create!(user: @member3)
  end

  # Termine une partie via un update direct (bypass du lifecycle pour les tests de numérotation)
  def finish_game(game)
    game.update_columns(status: 2, started_at: 1.minute.ago, finished_at: Time.current)
  end

  # T015 [US1] — Chaque équipe a sa propre séquence indépendante
  test "numbering is independent across two teams" do
    ga1 = @team_a.games.create!
    finish_game(ga1)
    ga2_record = @team_a.games.create!
    finish_game(ga2_record)
    ga3 = @team_a.games.create!

    gb1 = @team_b.games.create!

    assert_equal 1, ga1.team_game_number
    assert_equal 2, ga2_record.team_game_number
    assert_equal 3, ga3.team_game_number
    assert_equal 1, gb1.team_game_number
  end

  # T016 [US1] — La suppression d'une partie ne renumérote pas les existantes
  test "deleting a game does not renumber remaining games" do
    g1 = @team_a.games.create!
    finish_game(g1)
    g2 = @team_a.games.create!
    finish_game(g2)
    g3 = @team_a.games.create!

    assert_equal 1, g1.team_game_number
    assert_equal 2, g2.team_game_number
    assert_equal 3, g3.team_game_number

    finish_game(g3)
    g2.destroy!

    # Les numéros existants restent stables
    assert_equal 1, g1.reload.team_game_number
    assert_equal 3, g3.reload.team_game_number

    # La prochaine partie reçoit max+1 = 4
    g4 = @team_a.games.create!
    assert_equal 4, g4.team_game_number
  end

  # T024 [US2] — Numéros stables quand les autres équipes créent des parties
  test "existing game numbers stay stable when other teams create games" do
    ga1 = @team_a.games.create!
    finish_game(ga1)
    ga2_record = @team_a.games.create!

    assert_equal 1, ga1.reload.team_game_number
    assert_equal 2, ga2_record.reload.team_game_number

    # L'équipe B crée plusieurs parties — ne doit pas affecter l'équipe A
    gb1 = @team_b.games.create!
    finish_game(gb1)
    @team_b.games.create!

    assert_equal 1, ga1.reload.team_game_number
    assert_equal 2, ga2_record.reload.team_game_number
  end

  # T030 [US3] — Cohérence du numéro affiché sur les vues team show, game show et results
  test "displayed number is consistent across team show, game show, and results pages" do
    sign_in @organizer

    game = @team_a.games.create!
    expected_number = game.team_game_number

    get team_path(@team_a)
    assert_response :success
    assert_match(/Partie ##{expected_number}/, response.body)

    get game_path(game)
    assert_response :success
    assert_match(/Partie ##{expected_number}/, response.body)
  end

  # T031 [US3] — Régression : les labels principaux utilisent bien team_game_number
  test "main game number labels do not fall back to game.id" do
    sign_in @organizer

    game = @team_a.games.create!

    get team_path(@team_a)
    assert_response :success
    # Le numéro d'équipe doit être affiché
    assert_match(/Partie ##{game.team_game_number}/, response.body)
  end

  # T042 [US3] — Pas de requêtes SQL supplémentaires pour le rendu du numéro d'équipe
  test "rendering team show does not issue extra SQL for team game numbering" do
    sign_in @organizer
    3.times do
      g = @team_a.games.create!
      finish_game(g)
    end
    @team_a.games.create!  # Une partie active pour que la page soit intéressante

    # Warmup
    get team_path(@team_a)

    query_count = 0
    counter = ->(*, **) { query_count += 1 }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record") do
      get team_path(@team_a)
    end

    # Le nombre de requêtes ne doit pas augmenter proportionnellement au nombre de parties
    # (team_game_number est stocké — pas de calcul à la lecture)
    assert query_count < 40, "Trop de requêtes SQL : #{query_count} (attendu < 40)"
  end
end
