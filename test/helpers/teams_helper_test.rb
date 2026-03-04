require "test_helper"

class TeamsHelperTest < ActionView::TestCase
  setup do
    @organizer = User.create!(email: "teams_helper_org_#{SecureRandom.hex(4)}@example.com", name: "Org", password: "password123")
    @member = User.create!(email: "teams_helper_member_#{SecureRandom.hex(4)}@example.com", name: "Member", password: "password123")
    @team = Team.create!(name: "Helper Team", organizer: @organizer)
    @team.memberships.create!(user: @member)
  end

  test "leave_team_action_label uses locale translation when available" do
    I18n.with_locale(:fr) do
      assert_equal "Quitter l'équipe", leave_team_action_label
    end
  end

  test "leave_team_action_label falls back to default french label when translation missing" do
    original_en_translations = I18n.backend.send(:translations)[:en].deep_dup
    en_translations = I18n.backend.send(:translations)[:en]
    en_translations.deep_merge!(teams: { leave_action: {} }, "teams" => { "leave_action" => {} })

    if (teams_scope = en_translations[:teams] || en_translations["teams"])
      teams_scope.delete(:leave_action)
      teams_scope.delete("leave_action")
    end

    I18n.with_locale(:en) do
      assert_equal "Quitter l'équipe", leave_team_action_label
    end
  ensure
    I18n.backend.send(:translations)[:en] = original_en_translations
  end

  test "show_leave_team_action_for? is true for current non-organizer member row" do
    assert show_leave_team_action_for?(team: @team, member: @member, current_user: @member)
  end

  test "show_leave_team_action_for? is false for organizer" do
    assert_not show_leave_team_action_for?(team: @team, member: @organizer, current_user: @organizer)
  end

  test "show_leave_team_action_for? is false for other member rows" do
    assert_not show_leave_team_action_for?(team: @team, member: @organizer, current_user: @member)
  end
end
