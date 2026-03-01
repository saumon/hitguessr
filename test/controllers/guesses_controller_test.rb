require "test_helper"

# Tests contrôleur pour la feature 011: Randomisation de l'ordre des propositions
# Couvre T011 (US1 — même ordre pour deux joueurs), T017 (US2 — stabilité reload),
# T025 (US3 — edge cases 0/1 proposition)
class GuessesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @organizer = User.create!(name: "Organisateur", email: "organizer_gc@example.com", password: "password123")
    @player1   = User.create!(name: "Joueur 1",     email: "player1_gc@example.com",   password: "password123")
    @player2   = User.create!(name: "Joueur 2",     email: "player2_gc@example.com",   password: "password123")
    @player3   = User.create!(name: "Joueur 3",     email: "player3_gc@example.com",   password: "password123")

    @team = Team.create!(name: "Team GC", organizer: @organizer)
    @team.memberships.create!(user: @player1)
    @team.memberships.create!(user: @player2)
    @team.memberships.create!(user: @player3)

    @game = @team.games.create!

    # Créer 3 propositions avec un ordre de soumission connu
    @prop_a = @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @prop_b = @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @prop_c = @game.proposals.create!(player: @player3, url: "https://youtube.com/c")

    @game.start_guessing!
  end

  # =============================================================
  # T011 [US1] — Même ordre figé pour tous les joueurs de la manche
  # =============================================================

  test "GET new: proposals are ordered by guess_order_position ASC" do
    sign_in @player1
    get new_game_guess_path(@game)
    assert_response :success

    # Vérifier que les propositions reçues sont dans l'ordre figé (autres joueurs)
    expected_positions = @game.proposals.where.not(player: @player1)
                             .order(:guess_order_position, :id)
                             .pluck(:id)
    assign = controller.instance_variable_get(:@proposals)
    assert_equal expected_positions, assign.pluck(:id),
                 "Les propositions doivent être triées par guess_order_position ASC, id ASC"
  end

  test "GET new: two players see the same proposal order" do
    # Récupérer l'ordre depuis la perspective de @player3 (voit prop_a et prop_b)
    sign_in @player3
    get new_game_guess_path(@game)
    assert_response :success
    order_for_player3 = controller.instance_variable_get(:@proposals).pluck(:id)

    # Connexion avec @player1 (voit prop_b et prop_c)
    sign_out @player3
    sign_in @player1
    get new_game_guess_path(@game)
    assert_response :success
    order_for_player1 = controller.instance_variable_get(:@proposals).pluck(:id)

    # Les deux listes partagent les propositions communes avec le même ordre relatif
    common = order_for_player3 & order_for_player1
    assert common.length >= 1, "Il doit y avoir des propositions communes"

    # Les propositions communes doivent apparaître dans le même ordre relatif
    idx_p3 = order_for_player3.filter_map.with_index { |id, i| i if common.include?(id) }
    idx_p1 = order_for_player1.filter_map.with_index { |id, i| i if common.include?(id) }
    assert_equal idx_p3.map { |i| order_for_player3[i] },
                 idx_p1.map { |i| order_for_player1[i] },
                 "Les propositions communes doivent apparaître dans le même ordre relatif"
  end

  # =============================================================
  # T017 [US2] — Stabilité de l'ordre sur recharge multiple
  # =============================================================

  test "GET new: proposal order is stable across multiple requests for the same player" do
    sign_in @player1

    get new_game_guess_path(@game)
    first_order = controller.instance_variable_get(:@proposals).pluck(:id)

    get new_game_guess_path(@game)
    second_order = controller.instance_variable_get(:@proposals).pluck(:id)

    get new_game_guess_path(@game)
    third_order = controller.instance_variable_get(:@proposals).pluck(:id)

    assert_equal first_order, second_order, "L'ordre doit être stable entre les recharges (1ère vs 2ème)"
    assert_equal first_order, third_order, "L'ordre doit être stable entre les recharges (1ère vs 3ème)"
  end

  # =============================================================
  # T025 [US3] — Edge case: 0 proposition pour deviner (tous soumis)
  # =============================================================

  test "GET new: handles game with no proposals to guess redirects" do
    # Créer un joueur qui n'a pas de proposition = non autorisé
    extra_user = User.create!(name: "Extra", email: "extra_gc@example.com", password: "password123")
    @team.memberships.create!(user: extra_user)

    sign_in extra_user
    # Pas de proposition → authorize_has_proposal! doit rediriger
    get new_game_guess_path(@game)
    assert_redirected_to game_path(@game)
  end

  test "GET new: no timestamp-based ordering is used (order is by guess_order_position)" do
    sign_in @player2
    get new_game_guess_path(@game)
    assert_response :success

    proposals_returned = controller.instance_variable_get(:@proposals)

    # Vérifier que l'ordre retourné correspond bien à guess_order_position ASC, id ASC
    expected = @game.proposals.where.not(player: @player2)
                   .order(:guess_order_position, :id)
                   .to_a
    assert_equal expected.map(&:id), proposals_returned.map(&:id),
                 "L'ordre doit utiliser guess_order_position et non created_at"
  end
end
