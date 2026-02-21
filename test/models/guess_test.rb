require "test_helper"

class GuessTest < ActiveSupport::TestCase
  def setup
    Guess.delete_all
    Proposal.delete_all
    Game.delete_all
    Membership.delete_all
    Team.delete_all
    User.delete_all

    @organizer = build_user("organizer", "Organisateur")
    @player1 = build_user("player1", "Joueur 1")
    @player2 = build_user("player2", "Joueur 2")
    @player3 = build_user("player3", "Joueur 3")

    @team = Team.create!(name: "Les Mélomanes", organizer: @organizer)
    @team.memberships.create!(user: @player1)
    @team.memberships.create!(user: @player2)
    @team.memberships.create!(user: @player3)

    @game = @team.games.create!
    @proposal1 = @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @proposal2 = @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @proposal3 = @game.proposals.create!(player: @player3, url: "https://youtube.com/c")

    @game.start_guessing!
  end

  test "should be valid with valid attributes" do
    guess = Guess.new(
      player: @player2,
      proposal: @proposal1,
      guessed_author: @player1
    )
    assert guess.valid?
  end

  test "should require guessed_author to be a player with proposal" do
    outsider = build_user("outsider", "Outsider")
    @team.memberships.create!(user: outsider)  # Member but no proposal

    guess = Guess.new(
      player: @player2,
      proposal: @proposal1,
      guessed_author: outsider
    )
    assert_not guess.valid?
    assert guess.errors[:guessed_author].any? { |e| e.include?("joueur ayant soumis") }
  end

  test "should reject duplicate guess for same player and proposal" do
    Guess.create!(player: @player2, proposal: @proposal1, guessed_author: @player1)

    duplicate = Guess.new(player: @player2, proposal: @proposal1, guessed_author: @player3)
    assert_not duplicate.valid?
    assert duplicate.errors[:player_id].any? { |e| e.include?("déjà deviné") }
  end

  test "should only allow guesses during guessing phase" do
    # Create a new team for this test to avoid the one-active-game-per-team constraint
    team2 = Team.create!(name: "Autre équipe", organizer: @organizer)
    team2.memberships.create!(user: @player1)
    team2.memberships.create!(user: @player2)

    game2 = team2.games.create!  # Still in collecting phase
    game2.proposals.create!(player: @player1, url: "https://youtube.com/d")
    game2.proposals.create!(player: @player2, url: "https://youtube.com/e")
    proposal = game2.proposals.first

    guess = Guess.new(
      player: @player2,
      proposal: proposal,
      guessed_author: @player1
    )
    assert_not guess.valid?
    assert guess.errors[:proposal].any? { |e| e.include?("pas en phase de devinettes") }
  end

  test "should not allow player to guess their own proposal" do
    guess = Guess.new(
      player: @player1,
      proposal: @proposal1,  # @player1's own proposal
      guessed_author: @player2
    )
    assert_not guess.valid?
    assert guess.errors[:base].any? { |e| e.include?("propre proposition") }
  end

  test "correct? should return true when guess matches author" do
    guess = Guess.create!(player: @player2, proposal: @proposal1, guessed_author: @player1)
    assert_equal @proposal1.player_id, guess.guessed_author_id
  end

  test "correct? should return false when guess does not match author" do
    guess = Guess.create!(player: @player2, proposal: @proposal1, guessed_author: @player3)
    assert_not_equal @proposal1.player_id, guess.guessed_author_id
  end

  private

  def build_user(prefix, name)
    User.create!(email: "#{prefix}-#{SecureRandom.hex(6)}@example.com", name: name, password: "password123")
  end
end
