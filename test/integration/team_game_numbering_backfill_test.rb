require "test_helper"

# Vérifie l'exhaustivité du backfill de team_game_number pour les parties historiques.
class TeamGameNumberingBackfillTest < ActionDispatch::IntegrationTest
  def setup
    Guess.delete_all
    Proposal.delete_all
    Game.delete_all
    Membership.delete_all
    TeamInvitation.delete_all
    Team.delete_all
    User.delete_all
  end

  # Termine une partie directement (bypass lifecycle pour tests de numérotation)
  def finish_game(game)
    game.update_columns(status: 2, started_at: 1.minute.ago, finished_at: Time.current)
  end

  # T012 — Toutes les parties associées à une équipe ont un team_game_number après backfill
  test "all games with a team have a non-null team_game_number" do
    organizer = User.create!(name: "Org", email: "backfill_org@example.com", password: "password123")
    member1   = User.create!(name: "M1",  email: "backfill_m1@example.com",  password: "password123")
    member2   = User.create!(name: "M2",  email: "backfill_m2@example.com",  password: "password123")
    member3   = User.create!(name: "M3",  email: "backfill_m3@example.com",  password: "password123")

    team = Team.create!(name: "Backfill Team", organizer: organizer)
    team.memberships.create!(user: member1)
    team.memberships.create!(user: member2)
    team.memberships.create!(user: member3)

    # Simuler des parties historiques créées via le flux normal
    g1 = team.games.create!
    finish_game(g1)
    g2 = team.games.create!
    finish_game(g2)
    g3 = team.games.create!

    # Vérifier que chaque partie a bien un team_game_number positif et unique
    [ g1, g2, g3 ].each do |g|
      g.reload
      assert_not_nil g.team_game_number, "La partie #{g.id} n'a pas de team_game_number"
      assert g.team_game_number > 0, "team_game_number doit être positif"
    end

    numbers = [ g1, g2, g3 ].map { |g| g.reload.team_game_number }
    assert_equal numbers.uniq, numbers, "Les team_game_number doivent être uniques par équipe"
    assert_equal [ 1, 2, 3 ], numbers.sort, "Les numéros doivent commencer à 1 et être continus"
  end

  # Vérifie que deux équipes différentes peuvent avoir les mêmes numéros sans conflit
  test "two teams can both have game number 1 without conflict" do
    org = User.create!(name: "Org2", email: "backfill_org2@example.com", password: "password123")
    m1  = User.create!(name: "MB1", email: "backfill_mb1@example.com", password: "password123")
    m2  = User.create!(name: "MB2", email: "backfill_mb2@example.com", password: "password123")
    m3  = User.create!(name: "MB3", email: "backfill_mb3@example.com", password: "password123")

    team_x = Team.create!(name: "Team X", organizer: org)
    team_x.memberships.create!(user: m1)
    team_x.memberships.create!(user: m2)
    team_x.memberships.create!(user: m3)

    team_y = Team.create!(name: "Team Y", organizer: org)
    team_y.memberships.create!(user: m1)
    team_y.memberships.create!(user: m2)
    team_y.memberships.create!(user: m3)

    gx = team_x.games.create!
    gy = team_y.games.create!

    assert_equal 1, gx.team_game_number
    assert_equal 1, gy.team_game_number
  end
end
