require "application_system_test_case"

class ResponsiveGameTest < ApplicationSystemTestCase
  setup do
    @user = User.create!(
      email: "game_test@example.com",
      name: "Game Tester",
      password: "password123"
    )
    @member1 = User.create!(
      email: "game_member1@example.com",
      name: "Game Member 1",
      password: "password123"
    )
    @member2 = User.create!(
      email: "game_member2@example.com",
      name: "Game Member 2",
      password: "password123"
    )
    @team = Team.create!(name: "Test Team", organizer: @user)
    Membership.create!(user: @member1, team: @team)
    Membership.create!(user: @member2, team: @team)
    @game = Game.create!(team: @team, status: :collecting)
  end

  # US2: Expérience de jeu sur tablette
  test "game page is responsive on tablet" do
    resize_to_tablet
    sign_in_as @user

    visit game_path(@game)
    assert_no_horizontal_scroll

    # Phase indicator should be visible
    assert_selector ".neon-border"
  end

  test "game collecting phase is usable on mobile" do
    resize_to_mobile
    sign_in_as @user

    @game.update!(status: :collecting)

    visit game_path(@game)
    assert_no_horizontal_scroll

    assert_text "Progression:"
  end

  test "game guessing phase is usable on mobile" do
    resize_to_mobile
    sign_in_as @user

    # Create a proposal so we can move to guessing
    Proposal.create!(game: @game, player: @user, url: "https://example.com/song")
    Proposal.create!(game: @game, player: @member1, url: "https://example.com/song-2")
    @game.update!(status: :guessing, started_at: Time.current)

    visit game_path(@game)
    assert_no_horizontal_scroll
  end

  test "results page displays as cards on mobile" do
    resize_to_mobile
    sign_in_as @user

    @game.update!(status: :finished, started_at: Time.current, finished_at: Time.current)

    visit game_results_path(@game)
    assert_no_horizontal_scroll

    # Results should be in card format, not table
    assert_no_selector "table"
  end

  test "proposal form is usable on mobile" do
    resize_to_mobile
    sign_in_as @user

    @game.update!(status: :collecting)

    visit new_game_proposal_path(@game)
    assert_no_horizontal_scroll

    # Form should have proper touch targets
    submit_button = find("input[type=submit]")
    box = submit_button.native.rect
    assert box.height >= 44, "Submit button touch target height (#{box.height}px) is less than 44px"
  end

  test "game buttons have adequate touch targets on tablet" do
    resize_to_tablet
    sign_in_as @user

    visit game_path(@game)

    # All primary action buttons should be touchable
    all(".btn-neon.btn-primary").each do |button|
      box = button.native.rect
      if box.height > 0 # Only check visible buttons
        assert box.height >= 44, "Button touch target height (#{box.height}px) is less than 44px"
      end
    end
  end

  test "game transitions smoothly between viewports" do
    sign_in_as @user

    # Start on desktop
    resize_to_desktop
    visit game_path(@game)
    assert_no_horizontal_scroll

    # Switch to tablet
    resize_to_tablet
    sleep 0.3 # Allow for re-render
    assert_no_horizontal_scroll

    # Switch to mobile
    resize_to_mobile
    sleep 0.3
    assert_no_horizontal_scroll
  end
end
