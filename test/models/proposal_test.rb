require "test_helper"

class ProposalTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "player@example.com",
      name: "Joueur",
      password: "password123"
    )
    @organizer = User.create!(
      email: "organizer@example.com",
      name: "Organisateur",
      password: "password123"
    )
    @team = Team.create!(name: "Les Mélomanes", organizer: @organizer)
    @team.memberships.create!(user: @user)
    @game = @team.games.create!
  end

  test "should be valid with valid attributes" do
    proposal = Proposal.new(
      game: @game,
      player: @user,
      url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    )
    assert proposal.valid?
  end

  test "should require a URL" do
    proposal = Proposal.new(game: @game, player: @user, url: "")
    assert_not proposal.valid?
    assert_not proposal.errors[:url].empty?
  end

  test "should require valid URL format" do
    proposal = Proposal.new(game: @game, player: @user, url: "not-a-url")
    assert_not proposal.valid?
    assert proposal.errors[:url].any? { |e| e.include?("URL valide") }
  end

  test "should accept http URL" do
    proposal = Proposal.new(game: @game, player: @user, url: "http://example.com/song")
    assert proposal.valid?
  end

  test "should accept https URL" do
    proposal = Proposal.new(game: @game, player: @user, url: "https://example.com/song")
    assert proposal.valid?
  end

  test "should normalize URL - preserve case" do
    proposal = Proposal.create!(
      game: @game,
      player: @user,
      url: "HTTPS://WWW.YOUTUBE.COM/watch?v=ABC"
    )
    # Case is preserved (no lowercase conversion)
    assert_equal "HTTPS://WWW.YOUTUBE.COM/watch?v=ABC", proposal.url
  end

  test "should normalize URL - remove trailing slash" do
    proposal = Proposal.create!(
      game: @game,
      player: @user,
      url: "https://youtube.com/watch/"
    )
    assert_equal "https://youtube.com/watch", proposal.url
  end

  test "should normalize URL - remove fragment" do
    proposal = Proposal.create!(
      game: @game,
      player: @user,
      url: "https://youtube.com/watch?v=abc#t=30"
    )
    assert_equal "https://youtube.com/watch?v=abc", proposal.url
  end

  test "should reject duplicate URL in same game" do
    Proposal.create!(
      game: @game,
      player: @user,
      url: "https://youtube.com/watch?v=abc"
    )

    other_player = User.create!(email: "other@example.com", name: "Autre", password: "password123")
    @team.memberships.create!(user: other_player)

    duplicate = Proposal.new(
      game: @game,
      player: other_player,
      url: "https://youtube.com/watch?v=abc"
    )
    assert_not duplicate.valid?
    assert duplicate.errors[:url].any? { |e| e.include?("déjà été proposée") }
  end

  test "should reject duplicate URL after normalization" do
    Proposal.create!(
      game: @game,
      player: @user,
      url: "https://youtube.com/watch?v=abc"
    )

    other_player = User.create!(email: "other@example.com", name: "Autre", password: "password123")
    @team.memberships.create!(user: other_player)

    # Same URL with trailing slash (normalized to same)
    duplicate = Proposal.new(
      game: @game,
      player: other_player,
      url: "https://youtube.com/watch?v=abc/"
    )
    assert_not duplicate.valid?
  end

  test "should allow same URL in different games" do
    Proposal.create!(game: @game, player: @user, url: "https://youtube.com/watch?v=abc")

    # Finish the first game to allow creating a new one
    other_player = User.create!(email: "other2@example.com", name: "Autre2", password: "password123")
    @team.memberships.create!(user: other_player)
    @game.proposals.create!(player: other_player, url: "https://youtube.com/watch?v=xyz")
    @game.start_guessing!
    @game.finish!

    other_game = @team.games.create!
    proposal = Proposal.new(game: other_game, player: @user, url: "https://youtube.com/watch?v=abc")
    assert proposal.valid?
  end

  test "should reject multiple proposals from same player in same game" do
    Proposal.create!(game: @game, player: @user, url: "https://youtube.com/watch?v=abc")

    second_proposal = Proposal.new(
      game: @game,
      player: @user,
      url: "https://youtube.com/watch?v=xyz"
    )
    assert_not second_proposal.valid?
    assert second_proposal.errors[:player_id].any? { |e| e.include?("déjà soumis") }
  end

  test "should only allow proposals during collecting phase" do
    @game.proposals.create!(player: @user, url: "https://youtube.com/a")
    other_player = User.create!(email: "other@example.com", name: "Autre", password: "password123")
    @team.memberships.create!(user: other_player)
    @game.proposals.create!(player: other_player, url: "https://youtube.com/b")
    @game.start_guessing!

    third_player = User.create!(email: "third@example.com", name: "Troisième", password: "password123")
    @team.memberships.create!(user: third_player)

    late_proposal = Proposal.new(game: @game, player: third_player, url: "https://youtube.com/c")
    assert_not late_proposal.valid?
    assert late_proposal.errors[:game].any? { |e| e.include?("n'accepte plus") }
  end
end
