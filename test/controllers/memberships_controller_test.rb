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

  # ===========================================
  # Feature 012 – US2: Gestion membres (organisateur-only)
  # ===========================================

  # T020: non-organizer member cannot add a new member
  test "non-organizer member cannot add a member to the team" do
    new_user = User.create!(name: "Nouvel Utilisateur", email: "new_#{SecureRandom.hex(4)}@example.com", password: "password123")
    sign_in @member

    assert_no_difference("Membership.count") do
      post team_memberships_path(@team_one), params: { email: new_user.email }
    end

    assert_redirected_to team_path(@team_one)
    assert_equal I18n.t("authorization.organizer_only"), flash[:alert]
    assert_not @team_one.members.reload.include?(new_user)
  end

  # T020: organizer CAN add a new member (regression guard)
  test "organizer can add a member to the team" do
    new_user = User.create!(name: "Nouveau Membre", email: "new_member_#{SecureRandom.hex(4)}@example.com", password: "password123")
    sign_in @organizer

    assert_difference("Membership.count", 1) do
      post team_memberships_path(@team_one), params: { email: new_user.email }
    end

    assert_redirected_to team_path(@team_one)
    assert @team_one.members.reload.include?(new_user)
  end

  # T020: non-organizer member cannot remove another member
  test "non-organizer member cannot remove a member from the team" do
    sign_in @member

    assert_no_difference("Membership.count") do
      delete team_membership_path(@team_one, @organizer_membership)
    end

    assert_redirected_to team_path(@team_one)
    assert_equal I18n.t("authorization.organizer_only"), flash[:alert]
    assert Membership.exists?(id: @organizer_membership.id)
  end

  # T020: organizer CAN remove a non-organizer member (regression guard)
  test "organizer can remove a non-organizer member from the team" do
    sign_in @organizer

    assert_difference("Membership.count", -1) do
      delete team_membership_path(@team_one, @member_membership)
    end

    assert_redirected_to team_path(@team_one)
    assert_not Membership.exists?(id: @member_membership.id)
  end

  # T020 / T024: organizer cannot remove themselves (organizer non-removability invariant)
  test "organizer cannot remove themselves from the team" do
    sign_in @organizer

    assert_no_difference("Membership.count") do
      delete team_membership_path(@team_one, @organizer_membership)
    end

    assert_redirected_to team_path(@team_one)
    assert Membership.exists?(id: @organizer_membership.id)
  end
end
