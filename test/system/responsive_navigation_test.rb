require "application_system_test_case"

class ResponsiveNavigationTest < ApplicationSystemTestCase
  setup do
    @user = User.create!(
      email: "navigation_test@example.com",
      name: "Navigation Tester",
      password: "password123"
    )
  end

  # US1: Navigation mobile fluide
  test "navigation is accessible on mobile viewport" do
    resize_to_mobile
    sign_in_as @user

    visit root_path
    assert_no_horizontal_scroll

    # Logo HitGuessr is visible and accessible
    assert_selector "a", text: "HitGuessr"

    # "Mes équipes" link is visible
    assert_selector "a", text: "Mes équipes"

    # Déconnexion button is visible
    assert_selector "button", text: "Déconnexion"
  end

  test "no horizontal scroll on home page mobile" do
    resize_to_mobile
    visit root_path
    assert_no_horizontal_scroll
  end

  test "no horizontal scroll on teams index mobile" do
    resize_to_mobile
    sign_in_as @user
    visit teams_path
    assert_no_horizontal_scroll
  end

  test "navigation elements have adequate touch targets on mobile" do
    resize_to_mobile
    sign_in_as @user
    visit root_path

    # Logo link should have min 44px height
    logo_link = find("a", text: "HitGuessr")
    box = logo_link.native.rect
    assert box.height >= 44, "Logo touch target height (#{box.height}px) is less than 44px"

    # "Mes équipes" link should be touchable
    teams_link = find("a", text: "Mes équipes")
    box = teams_link.native.rect
    assert box.height >= 44, "Teams link touch target height (#{box.height}px) is less than 44px"
  end

  test "navigation works correctly on tablet" do
    resize_to_tablet
    sign_in_as @user

    visit root_path
    assert_no_horizontal_scroll
    assert_selector "a", text: "HitGuessr"
    assert_selector "a", text: "Mes équipes"
  end

  test "greeting is hidden on small mobile screens" do
    resize_to_mobile
    sign_in_as @user
    visit root_path

    # User greeting should be hidden on mobile (uses hidden sm:inline)
    # On mobile, only "Bonjour," is shown, the name is hidden
    assert_no_selector "span.hidden.sm\\:inline", text: @user.name, visible: true
  end

  test "greeting is visible on tablet" do
    resize_to_tablet
    sign_in_as @user
    visit root_path

    # On tablet (768px+), full greeting should be visible
    assert_text "Bonjour,"
  end

  test "can navigate to teams from mobile" do
    resize_to_mobile
    sign_in_as @user
    visit root_path

    click_on "Mes équipes"
    assert_current_path teams_path
    assert_no_horizontal_scroll
  end

  test "unauthenticated navigation on mobile" do
    resize_to_mobile
    visit root_path

    assert_no_horizontal_scroll
    assert_selector "a", text: "HitGuessr"
    assert_selector "a", text: "Connexion"
    assert_selector "a", text: "Inscription"
  end
end
