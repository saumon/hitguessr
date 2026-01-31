require "test_helper"

class GameTest < ActiveSupport::TestCase
  def setup
    @organizer = User.create!(email: "organizer@example.com", name: "Organisateur", password: "password123")
    @player1 = User.create!(email: "player1@example.com", name: "Joueur 1", password: "password123")
    @player2 = User.create!(email: "player2@example.com", name: "Joueur 2", password: "password123")
    @player3 = User.create!(email: "player3@example.com", name: "Joueur 3", password: "password123")

    @team = Team.create!(name: "Les Mélomanes", organizer: @organizer)
    @team.memberships.create!(user: @player1)
    @team.memberships.create!(user: @player2)
    @team.memberships.create!(user: @player3)

    @game = @team.games.create!
  end

  # Status tests
  test "should default to collecting status" do
    assert @game.collecting?
  end

  test "should have collecting, guessing, and finished statuses" do
    assert_equal({ "collecting" => 0, "guessing" => 1, "finished" => 2 }, Game.statuses)
  end

  # State transitions
  test "start_guessing! should transition from collecting to guessing" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")

    @game.start_guessing!

    assert @game.guessing?
    assert_not_nil @game.started_at
  end

  test "start_guessing! should require at least 2 proposals" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")

    assert_raises(Game::InvalidTransitionError) do
      @game.start_guessing!
    end
  end

  test "start_guessing! should fail if not in collecting phase" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @game.start_guessing!

    assert_raises(Game::InvalidTransitionError) do
      @game.start_guessing!
    end
  end

  test "finish! should transition from guessing to finished" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @game.start_guessing!

    @game.finish!

    assert @game.finished?
    assert_not_nil @game.finished_at
  end

  test "finish! should fail if not in guessing phase" do
    assert_raises(Game::InvalidTransitionError) do
      @game.finish!
    end
  end

  # Score calculation tests
  test "calculate_scores should return empty array for game with no guesses" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @game.start_guessing!
    @game.finish!

    scores = @game.calculate_scores
    assert_equal [], scores
  end

  test "calculate_scores should count correct guesses" do
    proposal1 = @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    proposal2 = @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @game.start_guessing!

    # Player2 guesses correctly for proposal1
    Guess.create!(player: @player2, proposal: proposal1, guessed_author: @player1)
    # Player1 guesses incorrectly for proposal2
    Guess.create!(player: @player1, proposal: proposal2, guessed_author: @player1)

    scores = @game.calculate_scores
    player2_score = scores.find { |s| s[:player] == @player2 }
    player1_score = scores.find { |s| s[:player] == @player1 }

    assert_equal 1, player2_score[:score]
    assert_equal 0, player1_score[:score]
  end

  # Ranking tests
  test "ranking should assign correct ranks" do
    proposal1 = @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    proposal2 = @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    proposal3 = @game.proposals.create!(player: @player3, url: "https://youtube.com/c")
    @game.start_guessing!

    # Player3 gets 2 correct
    Guess.create!(player: @player3, proposal: proposal1, guessed_author: @player1)
    Guess.create!(player: @player3, proposal: proposal2, guessed_author: @player2)

    # Player2 gets 1 correct
    Guess.create!(player: @player2, proposal: proposal1, guessed_author: @player1)
    Guess.create!(player: @player2, proposal: proposal3, guessed_author: @player1)  # Wrong

    # Player1 gets 0 correct
    Guess.create!(player: @player1, proposal: proposal2, guessed_author: @player3)  # Wrong
    Guess.create!(player: @player1, proposal: proposal3, guessed_author: @player2)  # Wrong

    ranking = @game.ranking

    assert_equal 1, ranking.find { |r| r[:player] == @player3 }[:rank]
    assert_equal 2, ranking.find { |r| r[:player] == @player2 }[:rank]
    assert_equal 3, ranking.find { |r| r[:player] == @player1 }[:rank]
  end

  test "ranking should handle ex aequo (same rank for same score)" do
    proposal1 = @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    proposal2 = @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    proposal3 = @game.proposals.create!(player: @player3, url: "https://youtube.com/c")
    @game.start_guessing!

    # Player2 and Player3 both get 1 correct
    Guess.create!(player: @player2, proposal: proposal1, guessed_author: @player1)  # Correct
    Guess.create!(player: @player2, proposal: proposal3, guessed_author: @player1)  # Wrong

    Guess.create!(player: @player3, proposal: proposal1, guessed_author: @player1)  # Correct
    Guess.create!(player: @player3, proposal: proposal2, guessed_author: @player1)  # Wrong

    # Player1 gets 0
    Guess.create!(player: @player1, proposal: proposal2, guessed_author: @player3)  # Wrong
    Guess.create!(player: @player1, proposal: proposal3, guessed_author: @player2)  # Wrong

    ranking = @game.ranking

    # Player2 and Player3 should both have rank 1
    assert_equal 1, ranking.find { |r| r[:player] == @player2 }[:rank]
    assert_equal 1, ranking.find { |r| r[:player] == @player3 }[:rank]
    # Player1 should have rank 3 (not 2, because there are 2 people tied at rank 1)
    assert_equal 3, ranking.find { |r| r[:player] == @player1 }[:rank]
  end

  test "players without guesses should have score 0" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    proposal2 = @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @game.start_guessing!

    # Only player1 submits guesses
    Guess.create!(player: @player1, proposal: proposal2, guessed_author: @player2)

    scores = @game.calculate_scores

    # Player1 has a score (1 correct)
    player1_score = scores.find { |s| s[:player] == @player1 }
    assert_equal 1, player1_score[:score]

    # Player2 doesn't appear in scores (no guesses submitted)
    player2_score = scores.find { |s| s[:player] == @player2 }
    assert_nil player2_score
  end
end
