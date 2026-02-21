require "test_helper"

class MembershipsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :teams, :memberships, :games

  setup do
    @organizer = users(:organizer)
    @member = users(:member)
    @team_one = teams(:team_one)
    @team_three = teams(:team_three)
    @organizer_membership = memberships(:organizer_membership)
    @member_membership = memberships(:member_membership)
    @member_membership_team_three = memberships(:member_membership_team_three)
  end

  test "unauthenticated user cannot leave a team" do
    assert_no_difference("Membership.count") do
      delete team_leave_path(@team_three)
    end

    assert_redirected_to new_user_session_path
  end

  test "member can leave team successfully when no active game" do
    sign_in @member

    assert_difference("Membership.count", -1) do
      delete team_leave_path(@team_three)
    end

    assert_redirected_to teams_path
    assert_equal I18n.t("memberships.leave.success"), flash[:notice]
    assert_not Membership.exists?(id: @member_membership_team_three.id)
  end

  test "organizer cannot leave their own team" do
    sign_in @organizer

    assert_no_difference("Membership.count") do
      delete team_leave_path(@team_one)
    end

    assert_redirected_to team_path(@team_one)
    assert_equal I18n.t("memberships.leave.organizer_forbidden"), flash[:alert]
    assert Membership.exists?(id: @organizer_membership.id)
  end

  test "member cannot leave when team has active game" do
    sign_in @member

    assert_no_difference("Membership.count") do
      delete team_leave_path(@team_one)
    end

    assert_redirected_to team_path(@team_one)
    assert_equal I18n.t("memberships.leave.active_game_forbidden"), flash[:alert]
    assert Membership.exists?(id: @member_membership.id)
  end

  test "idempotent leave returns clear message when already left" do
    sign_in @member

    delete team_leave_path(@team_three)

    assert_no_difference("Membership.count") do
      delete team_leave_path(@team_three)
    end

    assert_redirected_to teams_path
    assert_equal I18n.t("memberships.leave.already_left"), flash[:notice]
  end

  test "forged membership parameter cannot remove another user membership" do
    sign_in @member

    assert_difference("Membership.count", -1) do
      delete team_leave_path(@team_three), params: { membership_id: @organizer_membership.id }
    end

    assert Membership.exists?(id: @organizer_membership.id)
    assert_not Membership.exists?(id: @member_membership_team_three.id)
  end

  test "leave returns generic message for missing team" do
    sign_in @member

    assert_no_difference("Membership.count") do
      delete "/teams/999999/leave"
    end

    assert_redirected_to teams_path
    assert_equal I18n.t("memberships.leave.unauthorized"), flash[:alert]
  end
end
