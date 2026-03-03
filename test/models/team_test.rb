require "test_helper"

class TeamTest < ActiveSupport::TestCase
  def setup
    Guess.delete_all
    Proposal.delete_all
    Game.delete_all
    Membership.delete_all
    TeamInvitation.delete_all
    Team.delete_all
    User.delete_all

    @user = build_user("organizer", "Organisateur")
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
    game = create_game_for(team)

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
    create_game_for(team)

    assert_difference "Game.count", -1 do
      team.destroy
    end
  end

  # Active game helper tests (Feature 002)
  test "active_game should return the active game when one exists" do
    team = Team.create!(name: "Les Mélomanes", organizer: @user)
    game = create_game_for(team)
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

    game = create_game_for(team)
    game.proposals.create!(player: player1, url: "https://youtube.com/a")
    game.proposals.create!(player: player2, url: "https://youtube.com/b")
    game.start_guessing!
    game.finish! unless game.finished?

    assert_nil team.active_game
  end

  test "has_active_game? should return true when a collecting game exists" do
    team = Team.create!(name: "Les Mélomanes", organizer: @user)
    game = create_game_for(team)
    assert game.collecting?

    assert team.has_active_game?
  end

  test "has_active_game? should return true when a guessing game exists" do
    team = Team.create!(name: "Les Mélomanes", organizer: @user)
    player1 = User.create!(email: "p1@example.com", name: "Player 1", password: "password123")
    player2 = User.create!(email: "p2@example.com", name: "Player 2", password: "password123")
    team.memberships.create!(user: player1)
    team.memberships.create!(user: player2)

    game = create_game_for(team)
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

    game = create_game_for(team)
    game.proposals.create!(player: player1, url: "https://youtube.com/a")
    game.proposals.create!(player: player2, url: "https://youtube.com/b")
    game.start_guessing!
    game.finish! unless game.finished?

    assert_not team.has_active_game?
  end

  # Leaderboard tests (Feature 004)
  test "leaderboard should return empty array when no finished games" do
    team = Team.create!(name: "Les Mélomanes", organizer: @user)

    assert_equal [], team.leaderboard
  end

  test "leaderboard should return empty array when only active games exist" do
    team = Team.create!(name: "Les Mélomanes", organizer: @user)
    create_game_for(team) # collecting game

    assert_equal [], team.leaderboard
  end

  test "leaderboard should aggregate scores from multiple finished games" do
    team = Team.create!(name: "Les Mélomanes", organizer: @user)
    player1 = User.create!(email: "p1@example.com", name: "Player 1", password: "password123")
    player2 = User.create!(email: "p2@example.com", name: "Player 2", password: "password123")
    player3 = User.create!(email: "p3@example.com", name: "Player 3", password: "password123")
    team.memberships.create!(user: player1)
    team.memberships.create!(user: player2)
    team.memberships.create!(user: player3)

    # Game 1: 3 players, each guesses other's proposals
    game1 = create_game_for(team)
    prop1_g1 = game1.proposals.create!(player: player1, url: "https://youtube.com/a")
    prop2_g1 = game1.proposals.create!(player: player2, url: "https://youtube.com/b")
    prop3_g1 = game1.proposals.create!(player: player3, url: "https://youtube.com/c")
    game1.start_guessing!
    # player1 guesses prop2 and prop3 (both correct)
    prop2_g1.guesses.create!(player: player1, guessed_author: player2) # correct
    prop3_g1.guesses.create!(player: player1, guessed_author: player3) # correct
    # player2 guesses prop1 (correct) and prop3 (wrong)
    prop1_g1.guesses.create!(player: player2, guessed_author: player1) # correct
    prop3_g1.guesses.create!(player: player2, guessed_author: player1) # wrong
    # player3 guesses prop1 (wrong) and prop2 (wrong)
    prop1_g1.guesses.create!(player: player3, guessed_author: player2) # wrong
    prop2_g1.guesses.create!(player: player3, guessed_author: player1) # wrong
    game1.finish! unless game1.finished?
    # Game1 scores: player1=2, player2=1, player3=0

    # Game 2: player2 dominates
    game2 = create_game_for(team)
    prop1_g2 = game2.proposals.create!(player: player1, url: "https://youtube.com/d")
    prop2_g2 = game2.proposals.create!(player: player2, url: "https://youtube.com/e")
    prop3_g2 = game2.proposals.create!(player: player3, url: "https://youtube.com/f")
    game2.start_guessing!
    # player1 guesses 1 correct
    prop2_g2.guesses.create!(player: player1, guessed_author: player2) # correct
    prop3_g2.guesses.create!(player: player1, guessed_author: player1) # wrong
    # player2 guesses 2 correct
    prop1_g2.guesses.create!(player: player2, guessed_author: player1) # correct
    prop3_g2.guesses.create!(player: player2, guessed_author: player3) # correct
    # player3 guesses 0 correct
    prop1_g2.guesses.create!(player: player3, guessed_author: player2) # wrong
    prop2_g2.guesses.create!(player: player3, guessed_author: player1) # wrong
    game2.finish! unless game2.finished?
    # Game2 scores: player1=1, player2=2, player3=0

    leaderboard = team.leaderboard

    # Total: player1=3, player2=3, player3=0
    assert_equal 3, leaderboard.length
    assert_equal 3, leaderboard[0][:score]
    assert_equal 3, leaderboard[1][:score]
    assert_equal 0, leaderboard[2][:score]
  end

  test "leaderboard should sort by score descending" do
    team = Team.create!(name: "Les Mélomanes", organizer: @user)
    player1 = User.create!(email: "p1@example.com", name: "Player 1", password: "password123")
    player2 = User.create!(email: "p2@example.com", name: "Player 2", password: "password123")
    player3 = User.create!(email: "p3@example.com", name: "Player 3", password: "password123")
    team.memberships.create!(user: player1)
    team.memberships.create!(user: player2)
    team.memberships.create!(user: player3)

    game = create_game_for(team)
    prop1 = game.proposals.create!(player: player1, url: "https://youtube.com/a")
    prop2 = game.proposals.create!(player: player2, url: "https://youtube.com/b")
    prop3 = game.proposals.create!(player: player3, url: "https://youtube.com/c")
    game.start_guessing!
    # player2 scores 2 (guesses prop1 and prop3 correctly)
    prop1.guesses.create!(player: player2, guessed_author: player1)
    prop3.guesses.create!(player: player2, guessed_author: player3)
    # player1 scores 1 (guesses prop2 correctly)
    prop2.guesses.create!(player: player1, guessed_author: player2)
    prop3.guesses.create!(player: player1, guessed_author: player1) # wrong
    # player3 scores 0
    prop1.guesses.create!(player: player3, guessed_author: player2) # wrong
    prop2.guesses.create!(player: player3, guessed_author: player1) # wrong
    game.finish! unless game.finished?

    leaderboard = team.leaderboard

    assert_equal player2, leaderboard[0][:player]
    assert_equal 2, leaderboard[0][:score]
    assert_equal player1, leaderboard[1][:player]
    assert_equal 1, leaderboard[1][:score]
    assert_equal player3, leaderboard[2][:player]
    assert_equal 0, leaderboard[2][:score]
  end

  test "leaderboard should assign same rank to ex aequo players" do
    team = Team.create!(name: "Les Mélomanes", organizer: @user)
    player1 = User.create!(email: "p1@example.com", name: "Player 1", password: "password123")
    player2 = User.create!(email: "p2@example.com", name: "Player 2", password: "password123")
    player3 = User.create!(email: "p3@example.com", name: "Player 3", password: "password123")
    team.memberships.create!(user: player1)
    team.memberships.create!(user: player2)
    team.memberships.create!(user: player3)

    game = create_game_for(team)
    prop1 = game.proposals.create!(player: player1, url: "https://youtube.com/a")
    prop2 = game.proposals.create!(player: player2, url: "https://youtube.com/b")
    prop3 = game.proposals.create!(player: player3, url: "https://youtube.com/c")
    game.start_guessing!
    # player1 and player2 both score 1 (tied)
    prop2.guesses.create!(player: player1, guessed_author: player2) # correct
    prop3.guesses.create!(player: player1, guessed_author: player1) # wrong
    prop1.guesses.create!(player: player2, guessed_author: player1) # correct
    prop3.guesses.create!(player: player2, guessed_author: player1) # wrong
    # player3 scores 0
    prop1.guesses.create!(player: player3, guessed_author: player2) # wrong
    prop2.guesses.create!(player: player3, guessed_author: player1) # wrong
    game.finish! unless game.finished?

    leaderboard = team.leaderboard

    assert_equal 1, leaderboard[0][:rank]
    assert_equal 1, leaderboard[1][:rank]
    assert_equal 3, leaderboard[2][:rank]
  end

  test "leaderboard should handle game with 0 points for all players" do
    team = Team.create!(name: "Les Mélomanes", organizer: @user)
    player1 = User.create!(email: "p1@example.com", name: "Player 1", password: "password123")
    player2 = User.create!(email: "p2@example.com", name: "Player 2", password: "password123")
    player3 = User.create!(email: "p3@example.com", name: "Player 3", password: "password123")
    team.memberships.create!(user: player1)
    team.memberships.create!(user: player2)
    team.memberships.create!(user: player3)

    game = create_game_for(team)
    prop1 = game.proposals.create!(player: player1, url: "https://youtube.com/a")
    prop2 = game.proposals.create!(player: player2, url: "https://youtube.com/b")
    prop3 = game.proposals.create!(player: player3, url: "https://youtube.com/c")
    game.start_guessing!
    # All guesses are wrong
    prop2.guesses.create!(player: player1, guessed_author: player3) # wrong
    prop3.guesses.create!(player: player1, guessed_author: player2) # wrong
    prop1.guesses.create!(player: player2, guessed_author: player3) # wrong
    prop3.guesses.create!(player: player2, guessed_author: player1) # wrong
    prop1.guesses.create!(player: player3, guessed_author: player2) # wrong
    prop2.guesses.create!(player: player3, guessed_author: player1) # wrong
    game.finish! unless game.finished?

    leaderboard = team.leaderboard

    assert_equal 3, leaderboard.length
    assert_equal 0, leaderboard[0][:score]
    assert_equal 0, leaderboard[1][:score]
    assert_equal 0, leaderboard[2][:score]
    # All have rank 1 (tied at 0)
    assert_equal 1, leaderboard[0][:rank]
    assert_equal 1, leaderboard[1][:rank]
    assert_equal 1, leaderboard[2][:rank]
  end

  test "leaderboard should not include players who never made guesses" do
    team = Team.create!(name: "Les Mélomanes", organizer: @user)
    player1 = User.create!(email: "p1@example.com", name: "Player 1", password: "password123")
    player2 = User.create!(email: "p2@example.com", name: "Player 2", password: "password123")
    player3 = User.create!(email: "p3@example.com", name: "Player 3", password: "password123")
    team.memberships.create!(user: player1)
    team.memberships.create!(user: player2)
    team.memberships.create!(user: player3) # player3 is member but never guesses

    game = create_game_for(team)
    prop1 = game.proposals.create!(player: player1, url: "https://youtube.com/a")
    prop2 = game.proposals.create!(player: player2, url: "https://youtube.com/b")
    prop3 = game.proposals.create!(player: player3, url: "https://youtube.com/c")
    game.start_guessing!
    # Only player1 and player2 make guesses
    prop2.guesses.create!(player: player1, guessed_author: player2)
    prop3.guesses.create!(player: player1, guessed_author: player3)
    prop1.guesses.create!(player: player2, guessed_author: player1)
    prop3.guesses.create!(player: player2, guessed_author: player3)
    # player3 does not guess
    game.finish! unless game.finished?

    leaderboard = team.leaderboard

    assert_equal 2, leaderboard.length
    players_in_leaderboard = leaderboard.map { |e| e[:player] }
    assert_includes players_in_leaderboard, player1
    assert_includes players_in_leaderboard, player2
    assert_not_includes players_in_leaderboard, player3
  end

  test "leaderboard should not include scores from active games" do
    team = Team.create!(name: "Les Mélomanes", organizer: @user)
    player1 = User.create!(email: "p1@example.com", name: "Player 1", password: "password123")
    player2 = User.create!(email: "p2@example.com", name: "Player 2", password: "password123")
    player3 = User.create!(email: "p3@example.com", name: "Player 3", password: "password123")
    team.memberships.create!(user: player1)
    team.memberships.create!(user: player2)
    team.memberships.create!(user: player3)

    # Finished game
    game1 = create_game_for(team)
    prop1 = game1.proposals.create!(player: player1, url: "https://youtube.com/a")
    prop2 = game1.proposals.create!(player: player2, url: "https://youtube.com/b")
    prop3 = game1.proposals.create!(player: player3, url: "https://youtube.com/c")
    game1.start_guessing!
    prop2.guesses.create!(player: player1, guessed_author: player2)
    prop3.guesses.create!(player: player1, guessed_author: player3)
    prop1.guesses.create!(player: player2, guessed_author: player1)
    prop3.guesses.create!(player: player2, guessed_author: player1) # wrong
    game1.finish! unless game1.finished?

    leaderboard = team.leaderboard

    # Only scores from the finished game (game1)
    # player1: 2 correct, player2: 1 correct
    assert_equal 2, leaderboard.length
    assert_equal player1, leaderboard[0][:player]
    assert_equal 2, leaderboard[0][:score]
    assert_equal player2, leaderboard[1][:player]
    assert_equal 1, leaderboard[1][:score]
  end

  private

  def build_user(prefix, name)
    User.create!(email: "#{prefix}-#{SecureRandom.hex(6)}@example.com", name: name, password: "password123")
  end

  def ensure_minimum_members(team)
    missing = [ Game::MINIMUM_TEAM_MEMBERS - team.members.count, 0 ].max
    missing.times do
      team.memberships.create!(user: build_user("team-member", "Membre Test"))
    end
  end

  def create_game_for(team)
    ensure_minimum_members(team)
    team.games.create!
  end
end
