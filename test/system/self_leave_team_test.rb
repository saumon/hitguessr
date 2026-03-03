require "application_system_test_case"

class SelfLeaveTeamTest < ApplicationSystemTestCase
  setup do
    @organizer = User.create!(
      email: "self_leave_organizer@example.com",
      name: "Organisateur",
      password: "password123"
    )
    @organizer_two = User.create!(
      email: "self_leave_organizer_two@example.com",
      name: "Organisateur Deux",
      password: "password123"
    )
    @member = User.create!(
      email: "self_leave_member@example.com",
      name: "Membre",
      password: "password123"
    )
    @member_two = User.create!(
      email: "self_leave_member_two@example.com",
      name: "Membre Deux",
      password: "password123"
    )

    @team_one = Team.create!(name: "Équipe Alpha", organizer: @organizer)
    @team_one.memberships.create!(user: @member)
    @team_one.memberships.create!(user: @member_two)
    @team_one.games.create!(status: :collecting)

    @team_three = Team.create!(name: "Équipe Gamma", organizer: @organizer_two)
    @team_three.memberships.create!(user: @member)
  end

  test "member can leave team with exact confirmation text" do
    sign_in @member

    visit team_path(@team_three)

    assert_current_path team_path(@team_three)
    assert_text "Quitter"

    accept_confirm("Êtes-vous sûr de vouloir quitter cette équipe ?") do
      click_on "Quitter"
    end

    assert_current_path teams_path
    assert_text "Vous avez quitté l'équipe."
    assert_no_text @team_three.name
  end

  test "organizer does not see quitter button and stays member" do
    sign_in @organizer

    visit team_path(@team_one)

    assert_current_path team_path(@team_one)
    assert_no_text "Quitter"
    assert Membership.exists?(team: @team_one, user: @organizer)
  end

  test "member sees refusal message when active game exists" do
    sign_in @member

    visit team_path(@team_one)
    assert_current_path team_path(@team_one)

    accept_confirm("Êtes-vous sûr de vouloir quitter cette équipe ?") do
      click_on "Quitter"
    end

    assert_text "Impossible de quitter l'équipe pendant une partie en cours."
    assert Membership.exists?(team: @team_one, user: @member)
  end
end
