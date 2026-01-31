require "test_helper"

class TeamTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "organizer@example.com",
      name: "Organisateur",
      password: "password123"
    )
  end

  test "should be valid with valid attributes" do
    team = Team.new(name: "Les Mélomanes", organizer: @user)
    assert team.valid?
  end

  test "should require a name" do
    team = Team.new(name: "", organizer: @user)
    assert_not team.valid?
    assert_includes team.errors[:name], "ne peut pas être vide"
  end

  test "should require name minimum 2 characters" do
    team = Team.new(name: "A", organizer: @user)
    assert_not team.valid?
    assert team.errors[:name].any? { |e| e.include?("2") }
  end

  test "should require name maximum 100 characters" do
    team = Team.new(name: "A" * 101, organizer: @user)
    assert_not team.valid?
    assert team.errors[:name].any? { |e| e.include?("100") }
  end

  test "should require an organizer" do
    team = Team.new(name: "Les Mélomanes", organizer: nil)
    assert_not team.valid?
    assert_not team.errors[:organizer].empty?
  end

  test "should auto-create membership for organizer on create" do
    team = Team.create!(name: "Les Mélomanes", organizer: @user)
    assert_includes team.members, @user
    assert_equal 1, team.memberships.count
  end

  test "should have many members through memberships" do
    team = Team.create!(name: "Les Mélomanes", organizer: @user)
    member = User.create!(email: "member@example.com", name: "Membre", password: "password123")

    team.memberships.create!(user: member)

    assert_includes team.members, member
    assert_equal 2, team.members.count
  end

  test "should have many games" do
    team = Team.create!(name: "Les Mélomanes", organizer: @user)
    game = team.games.create!

    assert_includes team.games, game
  end

  test "should destroy memberships when destroyed" do
    team = Team.create!(name: "Les Mélomanes", organizer: @user)
    member = User.create!(email: "member@example.com", name: "Membre", password: "password123")
    team.memberships.create!(user: member)

    assert_difference "Membership.count", -2 do
      team.destroy
    end
  end

  test "should destroy games when destroyed" do
    team = Team.create!(name: "Les Mélomanes", organizer: @user)
    team.games.create!

    assert_difference "Game.count", -1 do
      team.destroy
    end
  end

  # Active game helper tests (Feature 002)
  test "active_game should return the active game when one exists" do
    team = Team.create!(name: "Les Mélomanes", organizer: @user)
    game = team.games.create!
    assert game.collecting?

    assert_equal game, team.active_game
  end

  test "active_game should return nil when no active game exists" do
    team = Team.create!(name: "Les Mélomanes", organizer: @user)

    assert_nil team.active_game
  end

  test "active_game should return nil when only finished games exist" do
    team = Team.create!(name: "Les Mélomanes", organizer: @user)
    player1 = User.create!(email: "p1@example.com", name: "Player 1", password: "password123")
    player2 = User.create!(email: "p2@example.com", name: "Player 2", password: "password123")
    team.memberships.create!(user: player1)
    team.memberships.create!(user: player2)

    game = team.games.create!
    game.proposals.create!(player: player1, url: "https://youtube.com/a")
    game.proposals.create!(player: player2, url: "https://youtube.com/b")
    game.start_guessing!
    game.finish!

    assert_nil team.active_game
  end

  test "has_active_game? should return true when a collecting game exists" do
    team = Team.create!(name: "Les Mélomanes", organizer: @user)
    game = team.games.create!
    assert game.collecting?

    assert team.has_active_game?
  end

  test "has_active_game? should return true when a guessing game exists" do
    team = Team.create!(name: "Les Mélomanes", organizer: @user)
    player1 = User.create!(email: "p1@example.com", name: "Player 1", password: "password123")
    player2 = User.create!(email: "p2@example.com", name: "Player 2", password: "password123")
    team.memberships.create!(user: player1)
    team.memberships.create!(user: player2)

    game = team.games.create!
    game.proposals.create!(player: player1, url: "https://youtube.com/a")
    game.proposals.create!(player: player2, url: "https://youtube.com/b")
    game.start_guessing!

    assert team.has_active_game?
  end

  test "has_active_game? should return false when no games exist" do
    team = Team.create!(name: "Les Mélomanes", organizer: @user)

    assert_not team.has_active_game?
  end

  test "has_active_game? should return false when only finished games exist" do
    team = Team.create!(name: "Les Mélomanes", organizer: @user)
    player1 = User.create!(email: "p1@example.com", name: "Player 1", password: "password123")
    player2 = User.create!(email: "p2@example.com", name: "Player 2", password: "password123")
    team.memberships.create!(user: player1)
    team.memberships.create!(user: player2)

    game = team.games.create!
    game.proposals.create!(player: player1, url: "https://youtube.com/a")
    game.proposals.create!(player: player2, url: "https://youtube.com/b")
    game.start_guessing!
    game.finish!

    assert_not team.has_active_game?
  end
end
