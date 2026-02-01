require "application_system_test_case"

class TeamLeaderboardTest < ApplicationSystemTestCase
  setup do
    @organizer = User.create!(
      email: "organizer@example.com",
      name: "Organisateur",
      password: "password123"
    )
    @player1 = User.create!(
      email: "player1@example.com",
      name: "Alice",
      password: "password123"
    )
    @player2 = User.create!(
      email: "player2@example.com",
      name: "Bob",
      password: "password123"
    )
    @player3 = User.create!(
      email: "player3@example.com",
      name: "Charlie",
      password: "password123"
    )

    @team = Team.create!(name: "Les Mélomanes", organizer: @organizer)
    @team.memberships.create!(user: @player1)
    @team.memberships.create!(user: @player2)
    @team.memberships.create!(user: @player3)

    sign_in @organizer
  end

  # US1: Display overall leaderboard
  test "displays leaderboard with cumulative scores sorted descending" do
    # Create a finished game with scores
    game = @team.games.create!
    prop1 = game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    prop2 = game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    prop3 = game.proposals.create!(player: @player3, url: "https://youtube.com/c")
    game.start_guessing!
    # player1 scores 2 (guesses prop2 and prop3 correctly)
    prop2.guesses.create!(player: @player1, guessed_author: @player2)
    prop3.guesses.create!(player: @player1, guessed_author: @player3)
    # player2 scores 1 (guesses prop1 correctly)
    prop1.guesses.create!(player: @player2, guessed_author: @player1)
    prop3.guesses.create!(player: @player2, guessed_author: @player1) # wrong
    # player3 scores 0
    prop1.guesses.create!(player: @player3, guessed_author: @player2) # wrong
    prop2.guesses.create!(player: @player3, guessed_author: @player1) # wrong
    game.finish!

    visit team_path(@team)

    # Check leaderboard section exists
    assert_text "Classement général"

    # Check players are displayed with scores
    within ".leaderboard-section" do
      assert_text "Alice"
      assert_text "2"
      assert_text "Bob"
      assert_text "1"
      assert_text "Charlie"
      assert_text "0"
    end
  end

  # US2: Display medals for top 3
  test "displays medals for top 3 players" do
    # Create a finished game
    game = @team.games.create!
    prop1 = game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    prop2 = game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    prop3 = game.proposals.create!(player: @player3, url: "https://youtube.com/c")
    game.start_guessing!
    # Set up scores: player1=2, player2=1, player3=0
    prop2.guesses.create!(player: @player1, guessed_author: @player2)
    prop3.guesses.create!(player: @player1, guessed_author: @player3)
    prop1.guesses.create!(player: @player2, guessed_author: @player1)
    prop3.guesses.create!(player: @player2, guessed_author: @player1) # wrong
    prop1.guesses.create!(player: @player3, guessed_author: @player2) # wrong
    prop2.guesses.create!(player: @player3, guessed_author: @player1) # wrong
    game.finish!

    visit team_path(@team)

    within ".leaderboard-section" do
      assert_text "🥇"
      assert_text "🥈"
      assert_text "🥉"
    end
  end

  test "displays same medal for ex aequo players" do
    # Create a finished game where player1 and player2 tie
    game = @team.games.create!
    prop1 = game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    prop2 = game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    prop3 = game.proposals.create!(player: @player3, url: "https://youtube.com/c")
    game.start_guessing!
    # player1 scores 1
    prop2.guesses.create!(player: @player1, guessed_author: @player2)
    prop3.guesses.create!(player: @player1, guessed_author: @player1) # wrong
    # player2 scores 1
    prop1.guesses.create!(player: @player2, guessed_author: @player1)
    prop3.guesses.create!(player: @player2, guessed_author: @player1) # wrong
    # player3 scores 0
    prop1.guesses.create!(player: @player3, guessed_author: @player2) # wrong
    prop2.guesses.create!(player: @player3, guessed_author: @player1) # wrong
    game.finish!

    visit team_path(@team)

    within ".leaderboard-section" do
      # Both tied players should have gold medal (rank 1)
      assert_selector "text, span", text: "🥇", count: 2
      # Third place should have bronze (rank 3, not silver)
      assert_text "🥉"
    end
  end

  # US3: Empty leaderboard message
  test "displays empty message when no finished games" do
    visit team_path(@team)

    assert_text "Classement général"
    assert_text "Aucun classement disponible"
  end

  test "displays empty message when only active games exist" do
    # Create an active game (collecting phase)
    @team.games.create!

    visit team_path(@team)

    assert_text "Classement général"
    assert_text "Aucun classement disponible"
  end
end
