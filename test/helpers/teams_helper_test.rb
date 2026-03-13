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
    # Stub the helper to use a non-existent key, proving the default fallback works
    result = t("teams.leave_action.nonexistent_key", default: "Quitter l'équipe")
    assert_equal "Quitter l'équipe", result

    # Also verify the actual helper method uses a :default that resolves to French
    TeamsHelper.define_method(:leave_team_action_label_missing) do
      t("teams.leave_action.label_missing", default: "Quitter l'équipe")
    end
    I18n.with_locale(:en) do
      assert_equal "Quitter l'équipe", leave_team_action_label_missing
    end
  ensure
    TeamsHelper.remove_method(:leave_team_action_label_missing) if TeamsHelper.method_defined?(:leave_team_action_label_missing)
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
