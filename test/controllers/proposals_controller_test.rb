require "test_helper"

# Tests contrôleur pour la feature 014: Modification de proposition avant guessing
# Couvre:
#   T010 [US1] — soumission en collecte crée si absence de proposition
#   T011 [US1] — utilisateur non membre ne peut ni créer ni modifier
#   T019 [US2] — soumission en guessing est refusée avec conservation de la valeur
#   T025 [US3] — absence de proposition + guessing => aucune création
class ProposalsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @organizer = User.create!(name: "Organisateur", email: "organizer_pct@example.com", password: "password123")
    @player1   = User.create!(name: "Joueur 1",     email: "player1_pct@example.com",   password: "password123")
    @player2   = User.create!(name: "Joueur 2",     email: "player2_pct@example.com",   password: "password123")
    @outsider  = User.create!(name: "Intrus",       email: "outsider_pct@example.com",  password: "password123")

    @team = Team.create!(name: "Team PCT", organizer: @organizer)
    @team.memberships.create!(user: @player1)
    @team.memberships.create!(user: @player2)

    @game = @team.games.create!
  end

  # =============================================================
  # T010 [US1] — soumission en collecte crée si absence de proposition
  # =============================================================

  test "soumission en collecte crée une proposition si aucune n'existe" do
    sign_in @player1

    assert_difference "@game.proposals.count", 1 do
      post game_proposals_path(@game), params: { proposal: { url: "https://youtube.com/watch?v=new" } }
    end

    assert_response :redirect
    assert_equal "https://youtube.com/watch?v=new", @game.proposals.find_by(player: @player1).url
  end

  test "soumission en collecte met à jour si une proposition existe déjà" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/watch?v=old")
    sign_in @player1

    assert_no_difference "@game.proposals.count" do
      post game_proposals_path(@game), params: { proposal: { url: "https://youtube.com/watch?v=updated" } }
    end

    assert_response :redirect
    assert_equal "https://youtube.com/watch?v=updated", @game.proposals.find_by(player: @player1).url
  end

  test "GET new affiche le formulaire même si une proposition existe déjà" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/watch?v=existing")
    sign_in @player1

    get new_game_proposal_path(@game)
    assert_response :success
  end

  test "GET new pré-remplit l'URL si une proposition existe" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/watch?v=existing")
    sign_in @player1

    get new_game_proposal_path(@game)
    assert_response :success
    assert_select "input[type='url'][value='https://youtube.com/watch?v=existing']"
  end

  # =============================================================
  # T011 [US1] — utilisateur non membre ne peut ni créer ni modifier
  # =============================================================

  test "utilisateur non membre ne peut pas accéder au formulaire de proposition" do
    sign_in @outsider

    get new_game_proposal_path(@game)
    assert_response :redirect
    assert_redirected_to teams_path
  end

  test "utilisateur non membre ne peut pas soumettre une proposition" do
    sign_in @outsider

    assert_no_difference "@game.proposals.count" do
      post game_proposals_path(@game), params: { proposal: { url: "https://youtube.com/watch?v=intrude" } }
    end

    assert_response :redirect
    assert_redirected_to teams_path
  end

  # =============================================================
  # T019 [US2] — soumission en guessing est refusée avec conservation de la valeur
  # =============================================================

  test "soumission en guessing est refusée et la valeur originale est conservée" do
    original_url = "https://youtube.com/watch?v=original"
    @game.proposals.create!(player: @player1, url: original_url)
    @game.proposals.create!(player: @player2, url: "https://youtube.com/watch?v=p2")
    @game.start_guessing!

    sign_in @player1

    assert_no_difference "@game.proposals.count" do
      post game_proposals_path(@game), params: { proposal: { url: "https://youtube.com/watch?v=illegal_update" } }
    end

    assert_response :redirect
    assert_equal original_url, @game.proposals.find_by(player: @player1).url,
                 "La valeur originale doit être conservée"
  end

  test "GET new est refusé en guessing et redirige" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/watch?v=p1")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/watch?v=p2")
    @game.start_guessing!

    sign_in @player1

    get new_game_proposal_path(@game)
    assert_response :redirect
    assert_redirected_to game_path(@game)
  end

  # =============================================================
  # T025 [US3] — absence de proposition + guessing => aucune création
  # =============================================================

  test "aucune proposition créée si la partie est en guessing et le joueur n'en a pas" do
    # Créer des propositions pour d'autres joueurs, passer en guessing
    @game.proposals.create!(player: @player2, url: "https://youtube.com/watch?v=p2")
    @game.proposals.create!(player: @organizer, url: "https://youtube.com/watch?v=org")
    @game.update_column(:status, Game.statuses[:guessing])

    sign_in @player1 # @player1 n'a pas de proposition

    assert_no_difference "@game.proposals.count" do
      post game_proposals_path(@game), params: { proposal: { url: "https://youtube.com/watch?v=late_create" } }
    end

    assert_response :redirect
    assert_nil @game.proposals.find_by(player_id: @player1.id),
               "Aucune proposition ne doit être créée en guessing"
  end
end
