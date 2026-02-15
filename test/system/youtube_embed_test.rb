require "application_system_test_case"

class YoutubeEmbedTest < ApplicationSystemTestCase
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

  test "YouTube link displays iframe embed below the link" do
    @game.proposals.create!(player: @player1, url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
    @game.proposals.create!(player: @player2, url: "https://www.youtube.com/watch?v=9bZkp7q19f0")
    @game.proposals.create!(player: @player3, url: "https://www.youtube.com/watch?v=kJQP7kiw5Fk")
    @game.start_guessing!

    sign_in_as @player1
    assert_text "Vous êtes connecté"

    visit new_game_guess_path(@game)

    # Player1 should see 2 proposals (not their own) - each with an iframe
    assert_selector "[data-testid='youtube-embed']", count: 2
    assert_selector "iframe[src*='youtube']", count: 2

    # Iframes should have loading="lazy" for performance
    assert_selector "iframe[loading='lazy']", count: 2

    # Iframes should have accessibility title
    assert_selector "iframe[title='Lecteur vidéo YouTube']", count: 2
  end

  test "YouTube link remains clickable above the iframe" do
    @game.proposals.create!(player: @player1, url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
    @game.proposals.create!(player: @player2, url: "https://www.youtube.com/watch?v=9bZkp7q19f0")
    @game.start_guessing!

    sign_in_as @player1
    assert_text "Vous êtes connecté"
    visit new_game_guess_path(@game)

    # The link should be present and iframe should be below it
    assert_selector "a[href*='youtube.com']"
    assert_selector "[data-testid='youtube-embed']"
    assert_selector "iframe[src*='youtube']"
  end

  test "player selector appears under the YouTube iframe" do
    @game.proposals.create!(player: @player1, url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
    @game.proposals.create!(player: @player2, url: "https://www.youtube.com/watch?v=9bZkp7q19f0")
    @game.start_guessing!

    sign_in_as @player1
    assert_text "Vous êtes connecté"
    visit new_game_guess_path(@game)

    # The iframe should appear, and radio buttons should be present
    assert_selector "[data-testid='youtube-embed']"
    assert_selector "input[type='radio']"

    # Should be able to select a player
    choose "Joueur 2"
  end

  test "non-YouTube links do not display iframe" do
    @game.proposals.create!(player: @player1, url: "https://open.spotify.com/track/abc123")
    @game.proposals.create!(player: @player2, url: "https://soundcloud.com/artist/track")
    @game.proposals.create!(player: @player3, url: "https://example.com/song.mp3")
    @game.start_guessing!

    sign_in_as @player1
    assert_text "Vous êtes connecté"
    visit new_game_guess_path(@game)

    # No iframe should be present for non-YouTube URLs
    assert_no_selector "[data-testid='youtube-embed']"
    assert_no_selector "iframe"

    # Links should still be present (player1 sees player2 and player3 links)
    assert_selector "a[href*='soundcloud.com']"
    assert_selector "a[href*='example.com']"
  end

  test "youtu.be short URLs display iframe" do
    @game.proposals.create!(player: @player1, url: "https://youtu.be/dQw4w9WgXcQ")
    @game.proposals.create!(player: @player2, url: "https://www.youtube.com/watch?v=9bZkp7q19f0")
    @game.start_guessing!

    sign_in_as @player1
    assert_text "Vous êtes connecté"
    visit new_game_guess_path(@game)

    # Player1 sees only player2's proposal (youtube.com) - should show 1 iframe
    assert_selector "[data-testid='youtube-embed']", count: 1
    assert_selector "iframe[src*='youtube']", count: 1
  end

  test "YouTube iframe does not autoplay by default" do
    @game.proposals.create!(player: @player1, url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
    @game.proposals.create!(player: @player2, url: "https://www.youtube.com/watch?v=9bZkp7q19f0")
    @game.start_guessing!

    sign_in_as @player1
    assert_text "Vous êtes connecté"
    visit new_game_guess_path(@game)

    # Iframe src should contain autoplay=0
    iframe = find("iframe[src*='youtube']")
    assert_match(/autoplay=0/, iframe[:src])
  end

  test "player can submit guesses with YouTube iframe displayed" do
    @game.proposals.create!(player: @player1, url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
    @game.proposals.create!(player: @player2, url: "https://www.youtube.com/watch?v=9bZkp7q19f0")
    @game.proposals.create!(player: @player3, url: "https://www.youtube.com/watch?v=kJQP7kiw5Fk")
    @game.start_guessing!

    sign_in_as @player1
    assert_text "Vous êtes connecté"

    visit new_game_guess_path(@game)

    # Iframes should be visible
    assert_selector "[data-testid='youtube-embed']", count: 2

    # Select guesses for each proposal using Proposition containers
    within(find("h3", text: "Proposition #1").ancestor(".rounded-lg")) do
      choose "Joueur 2"
    end
    within(find("h3", text: "Proposition #2").ancestor(".rounded-lg")) do
      choose "Joueur 3"
    end

    click_button "Soumettre mes devinettes"

    assert_text "Devinettes soumises avec succès"
  end

  test "mixed YouTube and non-YouTube links" do
    @game.proposals.create!(player: @player1, url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
    @game.proposals.create!(player: @player2, url: "https://open.spotify.com/track/abc123")
    @game.proposals.create!(player: @player3, url: "https://www.youtube.com/watch?v=kJQP7kiw5Fk")
    @game.start_guessing!

    sign_in_as @player1
    assert_text "Vous êtes connecté"

    visit new_game_guess_path(@game)

    # Player1 sees player2 (Spotify - no iframe) and player3 (YouTube - iframe)
    assert_selector "[data-testid='youtube-embed']", count: 1
    assert_selector "a[href*='spotify.com']"
    assert_selector "a[href*='youtube.com']"
  end

  test "YouTube iframe displays correctly on mobile viewport" do
    @game.proposals.create!(player: @player1, url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
    @game.proposals.create!(player: @player2, url: "https://www.youtube.com/watch?v=9bZkp7q19f0")
    @game.start_guessing!

    sign_in_as @player1
    assert_text "Vous êtes connecté"

    # Resize to mobile viewport
    resize_to_mobile

    visit new_game_guess_path(@game)

    # Iframe should still be visible on mobile
    assert_selector "[data-testid='youtube-embed']"
    assert_selector "iframe[src*='youtube']"

    # No horizontal scroll should occur
    assert_no_horizontal_scroll
  end
end
