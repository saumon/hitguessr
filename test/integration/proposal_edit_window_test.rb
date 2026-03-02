require "test_helper"

# Tests d'intégration pour la feature 014: Modification de proposition avant guessing
# Couvre:
#   T009 [US1] — create puis update via le même flux en collecte
#   T012 [US1] — mises à jour successives conservent un seul enregistrement
#   T017 [US2] — soumission en guessing ne modifie pas la proposition existante
#   T023 [US3] — bascule de phase entre affichage formulaire et submit
class ProposalEditWindowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @organizer = User.create!(name: "Organisateur", email: "organizer_pew@example.com", password: "password123")
    @player1   = User.create!(name: "Joueur 1",     email: "player1_pew@example.com",   password: "password123")
    @player2   = User.create!(name: "Joueur 2",     email: "player2_pew@example.com",   password: "password123")

    @team = Team.create!(name: "Team PEW", organizer: @organizer)
    @team.memberships.create!(user: @player1)
    @team.memberships.create!(user: @player2)

    @game = @team.games.create!
  end

  # =============================================================
  # T009 [US1] — create puis update via le même flux en collecte
  # =============================================================

  test "create puis update via le même flux en collecte" do
    sign_in @player1

    # Première soumission (création)
    post game_proposals_path(@game), params: { proposal: { url: "https://youtube.com/watch?v=first" } }
    assert_response :redirect
    follow_redirect!
    assert_response :success

    proposal = @game.proposals.find_by(player: @player1)
    assert_not_nil proposal, "La proposition doit être créée"
    assert_equal "https://youtube.com/watch?v=first", proposal.url

    # Deuxième soumission (mise à jour)
    post game_proposals_path(@game), params: { proposal: { url: "https://youtube.com/watch?v=updated" } }
    assert_response :redirect
    follow_redirect!
    assert_response :success

    proposal.reload
    assert_equal "https://youtube.com/watch?v=updated", proposal.url, "L'URL doit être mise à jour"
    assert_equal 1, @game.proposals.where(player: @player1).count, "Il ne doit exister qu'une seule proposition"
  end

  # =============================================================
  # T012 [US1] — mises à jour successives conservent un seul enregistrement
  # =============================================================

  test "mises à jour successives ne créent pas d'historique et conservent un seul enregistrement" do
    sign_in @player1

    urls = [
      "https://youtube.com/watch?v=v1",
      "https://youtube.com/watch?v=v2",
      "https://youtube.com/watch?v=v3"
    ]

    urls.each do |url|
      post game_proposals_path(@game), params: { proposal: { url: url } }
      assert_response :redirect
    end

    # Seul un enregistrement, avec la dernière URL
    assert_equal 1, @game.proposals.where(player: @player1).count,
                 "Seule une proposition doit exister après mises à jour successives"
    assert_equal urls.last, @game.proposals.find_by(player: @player1).url,
                 "La dernière URL soumise doit être conservée"
  end

  # =============================================================
  # T017 [US2] — soumission en guessing ne modifie pas la proposition existante
  # =============================================================

  test "soumission en guessing ne modifie pas la proposition existante" do
    original_url = "https://youtube.com/watch?v=original"
    @game.proposals.create!(player: @player1, url: original_url)
    @game.proposals.create!(player: @player2, url: "https://youtube.com/watch?v=other")
    @game.start_guessing!

    sign_in @player1

    post game_proposals_path(@game), params: { proposal: { url: "https://youtube.com/watch?v=attempt_guessing" } }
    assert_response :redirect

    # La valeur d'origine est conservée
    assert_equal original_url, @game.proposals.find_by(player_id: @player1.id).url,
                 "La proposition ne doit pas être modifiée en guessing"
  end

  # =============================================================
  # T023 [US3] — bascule de phase entre affichage formulaire et submit
  # =============================================================

  test "bascule de phase entre affichage formulaire et submit : la soumission post-bascule est refusée" do
    sign_in @player1

    # Simuler: joueur charge le formulaire en collecte
    get new_game_proposal_path(@game)
    assert_response :success

    # Pendant ce temps, le jeu bascule en guessing (triggered par un autre joueur)
    @game.proposals.create!(player: @player2, url: "https://youtube.com/watch?v=other")
    @game.proposals.create!(player: @organizer, url: "https://youtube.com/watch?v=third")
    # Forcer la transition manuellement (sans passer par start_guessing! qui est protégé)
    @game.update_column(:status, Game.statuses[:guessing])

    # Soumission après bascule: doit être refusée
    post game_proposals_path(@game), params: { proposal: { url: "https://youtube.com/watch?v=late_submit" } }
    assert_response :redirect

    # Aucune proposition créée pour player1
    assert_nil @game.proposals.find_by(player_id: @player1.id),
               "Aucune proposition ne doit être créée si la phase a basculé"
  end
end
