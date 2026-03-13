require "test_helper"

class GameTest < ActiveSupport::TestCase
  def setup
    Guess.delete_all
    Proposal.delete_all
    Game.delete_all
    Membership.delete_all
    TeamInvitation.delete_all
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

  # Single active game validation tests (Feature 002)
  test "should not allow creating a new game when a collecting game exists" do
    # @game is already created in setup and is collecting
    assert @game.collecting?

    new_game = @team.games.build
    assert_not new_game.valid?
    assert_includes new_game.errors[:base], "Une partie est déjà en cours pour cette équipe. Terminez-la avant d'en lancer une nouvelle."
  end

  test "should not allow creating a new game when a guessing game exists" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @game.start_guessing!
    assert @game.guessing?

    new_game = @team.games.build
    assert_not new_game.valid?
    assert_includes new_game.errors[:base], "Une partie est déjà en cours pour cette équipe. Terminez-la avant d'en lancer une nouvelle."
  end

  test "should allow creating a new game when no active game exists" do
    @game.destroy
    assert_not @team.has_active_game?

    new_game = @team.games.build
    assert new_game.valid?
  end

  test "should allow creating a new game when only finished games exist" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @game.start_guessing!
    @game.finish!
    assert @game.finished?

    new_game = @team.games.build
    assert new_game.valid?
    assert_difference "Game.count", 1 do
      new_game.save!
    end
  end

  test "Game.active scope should return only collecting and guessing games" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @game.start_guessing!
    @game.finish!

    # Now @game is finished, create a new active game
    new_game = @team.games.create!

    active_games = @team.games.active
    assert_includes active_games, new_game
    assert_not_includes active_games, @game
  end

  # Auto-progression detection tests (Feature 007)
  test "all_members_submitted? returns true when all team members have proposals" do
    # Team has 4 members: organizer, player1, player2, player3
    @game.proposals.create!(player: @organizer, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player1, url: "https://youtube.com/b")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/c")
    @game.proposals.create!(player: @player3, url: "https://youtube.com/d")

    assert @game.all_members_submitted?
  end

  test "all_members_submitted? returns false when not all team members have proposals" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")

    assert_not @game.all_members_submitted?
  end

  test "all_members_submitted? returns false with less than 2 proposals even if all submitted" do
    # Create a 3-member team with only 1 submitted proposal
    small_team = Team.create!(name: "Trio", organizer: @organizer)
    small_team.memberships.create!(user: @player1)
    small_team.memberships.create!(user: @player2)
    small_game = small_team.games.create!

    small_game.proposals.create!(player: @organizer, url: "https://youtube.com/a")

    # Less than 2 proposals and not all members submitted
    assert_not small_game.all_members_submitted?
  end

  test "all_members_submitted? with member added during collecting phase" do
    # Disable callback temporarily to test detection method in isolation
    Proposal.skip_callback(:commit, :after, :try_auto_progress_game)

    begin
      # Start with 4 proposals from all existing members (organizer + 3 players)
      @game.proposals.create!(player: @organizer, url: "https://youtube.com/org")
      @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
      @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
      @game.proposals.create!(player: @player3, url: "https://youtube.com/c")

      # All 4 members have submitted
      assert @game.all_members_submitted?

      # Add a new member to team
      new_player = build_user("new-player", "Nouveau")
      @team.memberships.create!(user: new_player)

      # Now should be false because new member hasn't submitted
      assert_not @game.all_members_submitted?

      # New member submits
      @game.proposals.create!(player: new_player, url: "https://youtube.com/d")
      assert @game.all_members_submitted?
    ensure
      Proposal.set_callback(:commit, :after, :try_auto_progress_game)
    end
  end

  test "all_members_submitted? with member removed during collecting phase" do
    # 2 out of 4 members submitted
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")

    assert_not @game.all_members_submitted?

    # Remove 2 members who haven't submitted (leaving 2 members with 2 proposals)
    @team.memberships.find_by(user: @player3).destroy
    @team.memberships.find_by(user: @organizer).destroy

    # Now 2 proposals for 2 members = all submitted
    assert @game.all_members_submitted?
  end

  test "expected_guesses_count returns correct value" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @game.proposals.create!(player: @player3, url: "https://youtube.com/c")

    # 3 proposals = 3 players * 2 proposals each to guess = 6
    assert_equal 6, @game.expected_guesses_count
  end

  test "all_guesses_submitted? returns true when all guesses are in" do
    proposal1 = @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    proposal2 = @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    proposal3 = @game.proposals.create!(player: @player3, url: "https://youtube.com/c")
    @game.start_guessing!

    # Each player guesses the other 2 proposals = 6 guesses total
    Guess.create!(player: @player1, proposal: proposal2, guessed_author: @player2)
    Guess.create!(player: @player1, proposal: proposal3, guessed_author: @player3)
    Guess.create!(player: @player2, proposal: proposal1, guessed_author: @player1)
    Guess.create!(player: @player2, proposal: proposal3, guessed_author: @player3)
    Guess.create!(player: @player3, proposal: proposal1, guessed_author: @player1)
    Guess.create!(player: @player3, proposal: proposal2, guessed_author: @player2)

    assert @game.all_guesses_submitted?
  end

  test "all_guesses_submitted? returns false when guesses are missing" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    proposal2 = @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @game.start_guessing!

    # Only 1 guess out of 2 expected
    Guess.create!(player: @player1, proposal: proposal2, guessed_author: @player2)

    assert_not @game.all_guesses_submitted?
  end

  # Auto-progression transition tests
  test "try_auto_progress_to_guessing! transitions when all members submitted" do
    @game.proposals.create!(player: @organizer, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player1, url: "https://youtube.com/b")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/c")
    @game.proposals.create!(player: @player3, url: "https://youtube.com/d")

    @game.try_auto_progress_to_guessing!

    assert @game.guessing?
    assert_not_nil @game.started_at
  end

  test "try_auto_progress_to_guessing! does not transition if not all submitted" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")

    @game.try_auto_progress_to_guessing!

    assert @game.collecting?
  end

  test "try_auto_progress_to_guessing! does not transition if less than 2 proposals" do
    # Create a 3-member team scenario with only one proposal
    small_team = Team.create!(name: "Trio Auto", organizer: @organizer)
    small_team.memberships.create!(user: @player1)
    small_team.memberships.create!(user: @player2)
    small_game = small_team.games.create!
    small_game.proposals.create!(player: @organizer, url: "https://youtube.com/a")

    small_game.try_auto_progress_to_guessing!

    assert small_game.collecting?
  end

  test "should not allow creating a game when team has fewer than three members" do
    small_team = Team.create!(name: "Duo", organizer: @organizer)
    small_team.memberships.create!(user: @player1)

    game = small_team.games.build

    assert_not game.valid?
    assert_includes game.errors[:base], I18n.t("games.create.minimum_members_required", count: Game::MINIMUM_TEAM_MEMBERS)
  end

  test "should allow creating a game when team has exactly three members and no active game" do
    team = Team.create!(name: "Trio Exact", organizer: @organizer)
    team.memberships.create!(user: @player1)
    team.memberships.create!(user: @player2)

    game = team.games.build

    assert game.valid?
  end

  test "try_auto_finish! transitions when all guesses submitted" do
    proposal1 = @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    proposal2 = @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @game.start_guessing!

    # 2 players, each guesses 1 proposal = 2 guesses
    Guess.create!(player: @player1, proposal: proposal2, guessed_author: @player2)
    Guess.create!(player: @player2, proposal: proposal1, guessed_author: @player1)

    @game.try_auto_finish!

    assert @game.finished?
    assert_not_nil @game.finished_at
  end

  test "try_auto_finish! does not transition if guesses missing" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    proposal2 = @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @game.start_guessing!

    # Only 1 guess out of 2
    Guess.create!(player: @player1, proposal: proposal2, guessed_author: @player2)

    @game.try_auto_finish!

    assert @game.guessing?
  end

  test "try_auto_finish! does not transition if not in guessing phase" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")

    # Still in collecting phase
    @game.try_auto_finish!

    assert @game.collecting?
  end

  # Non-regression tests (FR-006)
  test "start_guessing! manual transition still works after auto-progression feature" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")

    # Manual transition with only 2 proposals (not all 4 members)
    @game.start_guessing!

    assert @game.guessing?
  end

  test "finish! manual transition still works after auto-progression feature" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @game.start_guessing!

    # Manual finish without all guesses submitted
    @game.finish!

    assert @game.finished?
  end

  # =============================================================
  # Feature 011: Randomisation de l'ordre des propositions
  # =============================================================

  # T010 — [US1] Assignation aléatoire des positions au start_guessing!
  test "start_guessing! assigns guess_order_position to all proposals" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @game.proposals.create!(player: @player3, url: "https://youtube.com/c")

    # Vérifier que les positions sont nulles avant la transition
    @game.proposals.each do |p|
      assert_nil p.guess_order_position
    end

    @game.start_guessing!

    positions = @game.proposals.reload.pluck(:guess_order_position).sort
    assert_equal [ 1, 2, 3 ], positions, "Tous les positions doivent être 1..N"
  end

  test "start_guessing! assigns unique positions 1..N to proposals" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @game.proposals.create!(player: @player3, url: "https://youtube.com/c")

    @game.start_guessing!

    positions = @game.proposals.reload.pluck(:guess_order_position)
    assert_equal positions.length, positions.uniq.length, "Les positions doivent être uniques"
    assert positions.all? { |p| p >= 1 && p <= 3 }, "Les positions doivent être dans 1..N"
  end

  # T010 — [US2] Idempotence de l'assignation d'ordre
  test "start_guessing! is idempotent: does not reassign positions if already set" do
    p1 = @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    p2 = @game.proposals.create!(player: @player2, url: "https://youtube.com/b")

    # Assigner manuellement des positions pré-connues (simulation de résidu)
    p1.update_column(:guess_order_position, 1)
    p2.update_column(:guess_order_position, 2)

    @game.start_guessing!

    assert_equal 1, p1.reload.guess_order_position
    assert_equal 2, p2.reload.guess_order_position
  end

  # T010 — [US3] Indépendance des ordres entre deux parties
  test "two different games have independent guess order positions" do
    # Team 2 pour la 2ème partie
    team2 = Team.create!(name: "Team 2", organizer: @player3)
    team2.memberships.create!(user: @player1)
    team2.memberships.create!(user: @player2)
    game2 = team2.games.create!

    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    game2.proposals.create!(player: @player1, url: "https://youtube.com/c")
    game2.proposals.create!(player: @player2, url: "https://youtube.com/d")

    @game.start_guessing!
    game2.start_guessing!

    positions_game1 = Proposal.where(game: @game).pluck(:guess_order_position).sort
    positions_game2 = Proposal.where(game: game2).pluck(:guess_order_position).sort

    assert_equal [ 1, 2 ], positions_game1
    assert_equal [ 1, 2 ], positions_game2
  end

  # T010 — ordered_proposals_for_guessing helper
  test "ordered_proposals_for_guessing returns proposals sorted by position" do
    p1 = @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    p2 = @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    p3 = @game.proposals.create!(player: @player3, url: "https://youtube.com/c")

    # Assigner manuellement des positions pour tester l'ordre
    p1.update_column(:guess_order_position, 3)
    p2.update_column(:guess_order_position, 1)
    p3.update_column(:guess_order_position, 2)

    ordered_ids = @game.ordered_proposals_for_guessing.pluck(:id)
    assert_equal [ p2.id, p3.id, p1.id ], ordered_ids, "Doit être trié par guess_order_position ASC"
  end

  # ==============================================
  # Feature 012 – T010: Transition validity & concurrency conflict signaling
  # ==============================================

  # Transition invalide : start_guessing sur une partie déjà en guessing (état déjà changé)
  test "start_guessing! on an already-guessing game raises InvalidTransitionError (concurrent conflict)" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @game.start_guessing!

    # Simuler une seconde requête arrivant après la transition
    game_reload = Game.find(@game.id)
    error = assert_raises(Game::InvalidTransitionError) do
      game_reload.start_guessing!
    end

    assert_match(/phase de collecte/, error.message)
  end

  # Transition invalide : finish sur une partie déjà terminée
  test "finish! on an already-finished game raises InvalidTransitionError" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @game.start_guessing!
    @game.finish!

    game_reload = Game.find(@game.id)
    error = assert_raises(Game::InvalidTransitionError) do
      game_reload.finish!
    end

    assert_match(/phase de devinettes/, error.message)
  end

  # Transition invalide : finish depuis collecting (mauvais état)
  test "finish! from collecting state raises InvalidTransitionError" do
    assert @game.collecting?

    error = assert_raises(Game::InvalidTransitionError) do
      @game.finish!
    end

    assert_match(/phase de devinettes/, error.message)
    assert @game.reload.collecting?
  end

  # with_lock sérialise les transitions : le second appel concurrent reçoit InvalidTransitionError
  test "with_lock serializes concurrent start_guessing! – second call raises InvalidTransitionError" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")

    # Simuler deux références au même enregistrement (comme deux requêtes HTTP concurrentes)
    game_a = Game.find(@game.id)
    game_b = Game.find(@game.id)

    # Premier appel: réussit
    game_a.with_lock { game_a.start_guessing! }
    assert game_a.guessing?

    # Second appel: doit échouer car l'état a déjà changé
    assert_raises(Game::InvalidTransitionError) do
      game_b.with_lock { game_b.start_guessing! }
    end

    assert Game.find(@game.id).guessing?
  end

  # Idempotence de with_lock : un seul finish appliqué même avec deux références
  test "with_lock serializes concurrent finish! – second call raises InvalidTransitionError" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @game.start_guessing!

    game_a = Game.find(@game.id)
    game_b = Game.find(@game.id)

    game_a.with_lock { game_a.finish! }
    assert game_a.finished?

    assert_raises(Game::InvalidTransitionError) do
      game_b.with_lock { game_b.finish! }
    end

    assert Game.find(@game.id).finished?
  end

  private

  def build_user(prefix, name)
    User.create!(email: "#{prefix}-#{SecureRandom.hex(6)}@example.com", name: name, password: "password123")
  end

  # =============================================================
  # Feature 017: Public IDs — T011 Game public_id generation/format/retry
  # =============================================================

  public

  test "game gets a public_id on create with gm_ prefix" do
    assert @game.public_id.present?
    assert_match(/\Agm_[A-Za-z0-9]{8}\z/, @game.public_id)
  end

  test "game public_id is unique across games" do
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @game.start_guessing!
    @game.finish!
    game2 = @team.games.create!
    assert_not_equal @game.public_id, game2.public_id
  end

  test "game public_id is stable after reload" do
    original_id = @game.public_id
    @game.reload
    assert_equal original_id, @game.public_id
  end

  test "game to_param returns public_id" do
    assert_equal @game.public_id, @game.to_param
  end

  test "game public_id does not change on update" do
    original_id = @game.public_id
    @game.proposals.create!(player: @player1, url: "https://youtube.com/a")
    @game.proposals.create!(player: @player2, url: "https://youtube.com/b")
    @game.start_guessing!
    assert_equal original_id, @game.reload.public_id
  end

  # T052: Cross-model collision test
  test "game segment does not collide with existing team segment" do
    game_segments = Game.pluck(:public_id).map { |pid| pid.split("_", 2).last }
    team_segments = Team.pluck(:public_id).map { |pid| pid.split("_", 2).last }

    overlap = game_segments & team_segments
    assert_empty overlap, "Segments should not overlap between games and teams: #{overlap}"
  end
end
