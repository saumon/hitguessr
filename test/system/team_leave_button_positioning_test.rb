require "application_system_test_case"

class TeamLeaveButtonPositioningTest < ApplicationSystemTestCase
  setup do
    @organizer = User.create!(email: "position_org_#{SecureRandom.hex(4)}@example.com", name: "Position Organizer", password: "password123")
    @member = User.create!(email: "position_member_#{SecureRandom.hex(4)}@example.com", name: "Position Member", password: "password123")
    @other_member = User.create!(email: "position_other_#{SecureRandom.hex(4)}@example.com", name: "Position Other", password: "password123")

    @team = Team.create!(name: "Position Team", organizer: @organizer)
    @team.memberships.create!(user: @member)
    @team.memberships.create!(user: @other_member)
  end

  test "leave action is no longer displayed in header actions and appears on current member row" do
    resize_to_desktop
    sign_in_as @member

    visit team_path(@team)
    find("details.members-details summary").click

    assert_no_selector("[data-team-header-actions]", text: "Quitter l'équipe")
    assert_selector("[data-member-id='#{@member.id}'] button", text: "Quitter l'équipe")
    assert_no_selector("[data-member-id='#{@other_member.id}'] button", text: "Quitter l'équipe")
  end

  test "mobile layout keeps leave action on second line aligned right" do
    resize_to_mobile
    sign_in_as @member

    visit team_path(@team)
    find("details.members-details summary").click

    assert_selector("[data-member-id='#{@member.id}'] [data-member-actions].w-full.justify-end")
    assert_selector("[data-member-id='#{@member.id}'] button", text: "Quitter l'équipe")
  end

  test "member list remains readable with many members" do
    8.times do |index|
      user = User.create!(email: "position_long_#{index}_#{SecureRandom.hex(3)}@example.com", name: "Long Member #{index}", password: "password123")
      @team.memberships.create!(user: user)
    end

    resize_to_mobile
    sign_in_as @member

    visit team_path(@team)
    find("details.members-details summary").click

    assert_text "Long Member 0"
    assert_text "Long Member 7"
    assert_selector("[data-member-id='#{@member.id}'] button", text: "Quitter l'équipe")
  end

  test "leave action uses the same style classes as remove action" do
    resize_to_desktop

    sign_in_as @organizer
    visit team_path(@team)
    find("details.members-details summary").click

    remove_button_classes = find("[data-member-id='#{@member.id}'] button", text: "Retirer")[:class]

    Capybara.reset_sessions!

    sign_in_as @member
    visit team_path(@team)
    find("details.members-details summary").click

    leave_button_classes = find("[data-member-id='#{@member.id}'] button", text: "Quitter l'équipe")[:class]

    assert_equal remove_button_classes, leave_button_classes
  end
end
