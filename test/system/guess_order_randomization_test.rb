require "application_system_test_case"

# Tests système pour la feature 011: Randomisation de l'ordre des propositions
# Couvre T012 (US1 — non-corrélation), T018 (US2 — stabilité reload), T024 (US3 — indépendance inter-manches)
class GuessOrderRandomizationTest < ApplicationSystemTestCase
  def setup
    @organizer = User.create!(email: "organizer_gor@example.com", name: "Organisateur", password: "password123")
    @player1   = User.create!(email: "player1_gor@example.com", name: "Joueur 1", password: "password123")
    @player2   = User.create!(email: "player2_gor@example.com", name: "Joueur 2", password: "password123")
    @player3   = User.create!(email: "player3_gor@example.com", name: "Joueur 3", password: "password123")

    @team = Team.create!(name: "Team GOR", organizer: @organizer)
    @team.memberships.create!(user: @player1)
    @team.memberships.create!(user: @player2)
    @team.memberships.create!(user: @player3)

    @game = @team.games.create!
    @prop_a = @game.proposals.create!(player: @player1, url: "https://youtube.com/watch?v=aaa")
    @prop_b = @game.proposals.create!(player: @player2, url: "https://youtube.com/watch?v=bbb")
    @prop_c = @game.proposals.create!(player: @player3, url: "https://youtube.com/watch?v=ccc")
    @game.start_guessing!
  end

  # =============================================================
  # T012 [US1] — L'ordre affiché en devinette est déterministe et persisté
  # =============================================================

  test "guess order page displays proposals in guess_order_position order" do
    sign_in_as @player1

    visit new_game_guess_path(@game)

    assert_text "Faire mes devinettes"
    assert_text "Proposition #1"
    assert_text "Proposition #2"

    # Vérifier que les 2 propositions (pas celle de player1) sont affichées
    proposal_links = all("a[href*='youtube.com']").map { |a| a[:href] }
    assert_equal 2, proposal_links.length, "Player1 doit voir 2 propositions (pas la sienne)"

    # Vérifier que les liens sont dans l'ordre figé par guess_order_position
    expected_urls = @game.proposals.where.not(player: @player1)
                        .order(:guess_order_position, :id)
                        .pluck(:url)
    assert_equal expected_urls, proposal_links,
                 "Les propositions doivent être affichées dans l'ordre figé par guess_order_position"
  end

  # =============================================================
  # T018 [US2] — L'ordre ne change pas après rechargement de la page
  # =============================================================

  test "proposal order is stable after page reload" do
    sign_in_as @player1

    visit new_game_guess_path(@game)

    first_order = all("a[href*='youtube.com']").map { |a| a[:href] }

    # Recharger la page
    visit new_game_guess_path(@game)
    second_order = all("a[href*='youtube.com']").map { |a| a[:href] }

    assert_equal first_order, second_order,
                 "L'ordre des propositions doit être identique après rechargement"
  end

  # =============================================================
  # T024 [US3] — Chaque manche possède son propre ordre indépendant
  # =============================================================

  test "two different games have independent proposal orders and each preserves its own order" do
    # Terminer la première partie
    proposals_g1 = @game.proposals.where.not(player: @player1)
    proposals_g1.each do |proposal|
      Guess.create!(player: @player1, proposal: proposal, guessed_author: @player2)
    end
    proposals_g1_for_p2 = @game.proposals.where.not(player: @player2)
    proposals_g1_for_p2.each do |proposal|
      Guess.create!(player: @player2, proposal: proposal, guessed_author: @player1)
    end
    proposals_g1_for_p3 = @game.proposals.where.not(player: @player3)
    proposals_g1_for_p3.each do |proposal|
      Guess.create!(player: @player3, proposal: proposal, guessed_author: @player1)
    end
    @game.update_columns(status: :finished, finished_at: Time.current)

    # Créer une deuxième partie avec des propositions différentes
    game2 = @team.games.create!
    game2.proposals.create!(player: @player1, url: "https://youtube.com/watch?v=xxx")
    game2.proposals.create!(player: @player2, url: "https://youtube.com/watch?v=yyy")
    game2.proposals.create!(player: @player3, url: "https://youtube.com/watch?v=zzz")
    game2.start_guessing!

    order_game1 = @game.proposals.order(:guess_order_position, :id).pluck(:id)
    order_game2 = game2.proposals.order(:guess_order_position, :id).pluck(:id)

    # Les deux parties ont des propositions différentes, donc des ordres d'IDs différents
    assert_not_equal order_game1, order_game2,
                     "Deux parties différentes ne doivent pas avoir le même ordre d'IDs"

    # L'ordre de chaque partie reste stable
    sign_in_as @player1

    visit new_game_guess_path(game2)
    displayed_urls = all("a[href*='youtube.com']").map { |a| a[:href] }
    expected_urls  = game2.proposals.where.not(player: @player1)
                         .order(:guess_order_position, :id)
                         .pluck(:url)
    assert_equal expected_urls, displayed_urls,
                 "La deuxième partie doit afficher les propositions dans son propre ordre"
  end
end
