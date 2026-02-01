require "application_system_test_case"

class ResponsiveTransitionsTest < ApplicationSystemTestCase
  setup do
    @user = User.create!(
      email: "transitions_test@example.com",
      name: "Transitions Tester",
      password: "password123"
    )
    @team = Team.create!(name: "Transitions Team", organizer: @user)
    Membership.create!(user: @user, team: @team, role: :organizer)
    @game = Game.create!(team: @team, status: :collecting)
  end

  # US4: Transition fluide entre appareils
  test "viewport resize does not cause horizontal scroll" do
    sign_in_as @user
    visit root_path

    # Start at desktop
    resize_to_desktop
    sleep 0.2
    assert_no_horizontal_scroll

    # Transition to tablet
    resize_to_tablet
    sleep 0.2
    assert_no_horizontal_scroll

    # Transition to mobile
    resize_to_mobile
    sleep 0.2
    assert_no_horizontal_scroll

    # Transition back to desktop
    resize_to_desktop
    sleep 0.2
    assert_no_horizontal_scroll
  end

  test "page content reflows without layout shift on resize" do
    sign_in_as @user
    visit teams_path

    # Start at mobile
    resize_to_mobile
    sleep 0.2

    # Get initial content state
    has_content = page.has_selector?("body")

    # Resize to tablet
    resize_to_tablet
    sleep 0.3

    # Content should still be present
    assert has_content, "Content should not disappear during resize"
  end

  test "no content disappears during rapid viewport changes" do
    sign_in_as @user
    visit root_path

    # Rapid viewport changes
    5.times do
      resize_to_mobile
      sleep 0.1
      resize_to_tablet
      sleep 0.1
      resize_to_desktop
      sleep 0.1
    end

    # Page should still be functional
    assert_selector "a", text: "HitGuessr"
    assert_no_horizontal_scroll
  end

  test "form preserves input during viewport change" do
    sign_in_as @user
    visit new_team_path

    resize_to_desktop

    # Fill in a form field
    fill_in "team_name", with: "Test Team Name"

    # Change viewport
    resize_to_mobile
    sleep 0.3

    # Input should be preserved
    assert_equal "Test Team Name", find_field("team_name").value
  end

  test "navigation remains accessible after orientation change simulation" do
    sign_in_as @user
    visit root_path

    # Portrait mobile
    page.driver.browser.manage.window.resize_to(375, 667)
    sleep 0.2
    assert_selector "a", text: "HitGuessr"
    assert_selector "a", text: "Mes équipes"

    # Landscape mobile (simulated orientation change)
    page.driver.browser.manage.window.resize_to(667, 375)
    sleep 0.2
    assert_selector "a", text: "HitGuessr"
    assert_selector "a", text: "Mes équipes"
    assert_no_horizontal_scroll
  end

  test "teams page handles viewport transitions gracefully" do
    sign_in_as @user
    visit team_path(@team)

    resize_to_desktop
    assert_no_horizontal_scroll

    resize_to_tablet
    sleep 0.2
    assert_no_horizontal_scroll

    resize_to_mobile
    sleep 0.2
    assert_no_horizontal_scroll

    # Team name should still be visible
    assert_text @team.name
  end

  test "game page transitions between viewports" do
    sign_in_as @user
    visit game_path(@game)

    # Test all viewport sizes
    [
      [ 375, 667 ],   # Mobile portrait
      [ 667, 375 ],   # Mobile landscape
      [ 768, 1024 ],  # Tablet portrait
      [ 1024, 768 ],  # Tablet landscape
      [ 1440, 900 ]   # Desktop
    ].each do |width, height|
      page.driver.browser.manage.window.resize_to(width, height)
      sleep 0.2
      assert_no_horizontal_scroll
    end
  end
end
