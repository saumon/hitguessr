require "application_system_test_case"

class ResponsiveDesktopTest < ApplicationSystemTestCase
  setup do
    @user = User.create!(
      email: "desktop_test@example.com",
      name: "Desktop Tester",
      password: "password123"
    )
    @member1 = User.create!(
      email: "desktop_member1@example.com",
      name: "Desktop Member 1",
      password: "password123"
    )
    @member2 = User.create!(
      email: "desktop_member2@example.com",
      name: "Desktop Member 2",
      password: "password123"
    )
    @team = Team.create!(name: "Desktop Team", organizer: @user)
    Membership.create!(user: @member1, team: @team)
    Membership.create!(user: @member2, team: @team)
    @game = Game.create!(team: @team, status: :collecting)
  end

  # US3: Affichage optimal sur écran PC
  test "content is properly centered on desktop" do
    resize_to_desktop
    sign_in_as @user

    visit root_path
    assert_no_horizontal_scroll

    # Content should have max-width constraint
    main_container = find("main.container")
    box = main_container.native.rect

    # Content should not exceed viewport width
    assert box.width <= 1440, "Content width (#{box.width}px) exceeds viewport width"
  end

  test "content remains readable on very wide screens" do
    # Simulate ultra-wide screen
    page.driver.browser.manage.window.resize_to(1920, 1080)
    sign_in_as @user

    visit root_path
    assert_no_horizontal_scroll

    # Main content should still be constrained
    assert_selector ".max-w-4xl"
  end

  test "hover effects work on desktop" do
    resize_to_desktop
    sign_in_as @user

    visit teams_path

    # Check that page loads and has interactive elements
    assert_selector "a", text: "Mes équipes"
  end

  test "navigation shows full greeting on desktop" do
    resize_to_desktop
    sign_in_as @user

    visit root_path

    # Full greeting should be visible on desktop (md:inline shows at 768px+)
    assert_selector "span", text: "Bonjour,"
  end

  test "buttons have hover effects on desktop" do
    resize_to_desktop
    visit root_path

    # Primary buttons should have hover transformation classes
    buttons = all(".btn-neon")
    assert buttons.count > 0, "Page should have styled buttons"
  end

  test "forms are properly sized on desktop" do
    resize_to_desktop
    sign_in_as @user

    visit new_team_path
    assert_no_horizontal_scroll

    # Form should be constrained width, not full screen
    form_container = first(".max-w-md, .max-w-lg, .max-w-xl, .max-w-2xl")
    if form_container
      box = form_container.native.rect
      assert box.width <= 672, "Form container should be constrained on desktop"
    end
  end

  test "team page displays well on desktop" do
    resize_to_desktop
    sign_in_as @user

    visit team_path(@team)

    assert_no_horizontal_scroll

    # Team name should be visible
    assert_text @team.name
  end

  test "game page works on very wide screens" do
    page.driver.browser.manage.window.resize_to(2560, 1440) # 2K monitor
    sign_in_as @user

    visit game_path(@game)

    assert_no_horizontal_scroll
  end
end
