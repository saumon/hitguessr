require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  include Devise::Test::IntegrationHelpers

  def sign_in_as(user)
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Mot de passe", with: "password123"
    click_button "Se connecter"
  end

  # Responsive viewport helpers
  def resize_to_mobile
    page.driver.browser.manage.window.resize_to(375, 667) # iPhone SE
  end

  def resize_to_tablet
    page.driver.browser.manage.window.resize_to(768, 1024) # iPad
  end

  def resize_to_desktop
    page.driver.browser.manage.window.resize_to(1440, 900) # Desktop
  end

  def assert_no_horizontal_scroll
    scroll_width = page.evaluate_script("document.documentElement.scrollWidth")
    client_width = page.evaluate_script("document.documentElement.clientWidth")
    assert scroll_width <= client_width, "Horizontal scroll detected: scrollWidth=#{scroll_width}, clientWidth=#{client_width}"
  end

  def assert_element_visible(selector)
    element = find(selector, visible: :all)
    box = element.native.rect
    assert box.width > 0 && box.height > 0, "Element #{selector} is not visible"
  end

  def assert_touch_target_size(selector, min_size: 44)
    element = find(selector, visible: :all)
    box = element.native.rect
    assert box.width >= min_size, "Touch target width (#{box.width}px) is less than #{min_size}px for #{selector}"
    assert box.height >= min_size, "Touch target height (#{box.height}px) is less than #{min_size}px for #{selector}"
  end
end
