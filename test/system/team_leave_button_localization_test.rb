require "application_system_test_case"

class TeamLeaveButtonLocalizationTest < ApplicationSystemTestCase
  setup do
    @organizer = User.create!(email: "locale_org_#{SecureRandom.hex(4)}@example.com", name: "Locale Organizer", password: "password123")
    @member = User.create!(email: "locale_member_#{SecureRandom.hex(4)}@example.com", name: "Locale Member", password: "password123")
    @team = Team.create!(name: "Locale Team", organizer: @organizer)
    @team.memberships.create!(user: @member)
  end

  test "leave action label is localized in french" do
    sign_in_as @member

    visit team_path(@team)
    find("details.members-details summary").click

    assert_selector("button", text: "Quitter l'équipe")
  end

  test "leave action label falls back to french default when locale has no translation" do
    sign_in_as @member

    original_en_translations = I18n.backend.send(:translations)[:en].deep_dup
    previous_default_locale = I18n.default_locale
    I18n.backend.send(:translations)[:en].deep_merge!(teams: { leave_action: {} })
    I18n.backend.send(:translations)[:en][:teams].delete(:leave_action)
    I18n.default_locale = :en

    visit team_path(@team)
    find("details.members-details summary").click

    assert_selector("button", text: "Quitter l'équipe")
  ensure
    I18n.backend.send(:translations)[:en] = original_en_translations
    I18n.default_locale = previous_default_locale
  end
end
