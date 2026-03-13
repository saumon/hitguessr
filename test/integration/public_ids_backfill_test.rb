require "test_helper"

class PublicIdsBackfillTest < ActionDispatch::IntegrationTest
  test "all games have valid public_id after migration" do
    # Create some games to verify the concern generates IDs
    organizer = User.create!(name: "Org", email: "org-backfill-#{SecureRandom.hex(4)}@example.com", password: "password123")
    p1 = User.create!(name: "P1", email: "p1-backfill-#{SecureRandom.hex(4)}@example.com", password: "password123")
    p2 = User.create!(name: "P2", email: "p2-backfill-#{SecureRandom.hex(4)}@example.com", password: "password123")

    team = Team.create!(name: "Backfill Team", organizer: organizer)
    team.memberships.create!(user: p1)
    team.memberships.create!(user: p2)
    team.games.create!

    assert_all_backfilled(Game)
  end

  test "all teams have valid public_id after migration" do
    organizer = User.create!(name: "Org", email: "org-backfill2-#{SecureRandom.hex(4)}@example.com", password: "password123")
    Team.create!(name: "Backfill Team 2", organizer: organizer)

    assert_all_backfilled(Team)
  end

  test "no duplicate segments across games and teams" do
    game_segments = Game.pluck(:public_id).map { |pid| pid.split("_", 2).last }
    team_segments = Team.pluck(:public_id).map { |pid| pid.split("_", 2).last }

    overlap = game_segments & team_segments
    assert_empty overlap, "Segments should not overlap between Game and Team: #{overlap}"
  end
end
