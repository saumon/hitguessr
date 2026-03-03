require "test_helper"

class TeamsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :teams, :memberships, :team_invitations

  setup do
    @organizer  = users(:organizer)
    @member     = users(:member)
    @non_member = users(:non_member)
    @team_one   = teams(:team_one)
    @pending    = team_invitations(:pending_invitation)
  end

  # ============================================================
  # US3 – T025: Visibilité des pending invitations par rôle
  # ============================================================

  test "active member can access team show page" do
    sign_in @member

    get team_path(@team_one)

    assert_response :success
  end

  test "organizer can access team show page" do
    sign_in @organizer

    get team_path(@team_one)

    assert_response :success
  end

  test "team show page contains pending invitation data for active member" do
    sign_in @member

    get team_path(@team_one)

    assert_response :success
    # Vérifie que la page affiche bien l'invité en attente (non_member)
    assert_select "[data-invitation-id='#{@pending.id}']"
  end

  test "team show page contains pending invitation data for organizer" do
    sign_in @organizer

    get team_path(@team_one)

    assert_response :success
    assert_select "[data-invitation-id='#{@pending.id}']"
  end

  test "invitee sees accept and refuse buttons on team page" do
    sign_in @non_member

    get team_path(@team_one)

    assert_response :success
    # Accepter/Refuser sont dans des formulaires button_to
    assert_select "form[action='#{accept_team_invitation_path(@team_one, @pending)}']"
    assert_select "form[action='#{refuse_team_invitation_path(@team_one, @pending)}']"
  end

  test "unauthenticated user is redirected from team show" do
    get team_path(@team_one)

    assert_redirected_to new_user_session_path
  end

  # ============================================================
  # US3 – T025: Invitations visible sur la page index /teams
  # ============================================================

  test "invited user sees pending invitation on teams index page" do
    sign_in @non_member

    get teams_path

    assert_response :success
    # Le nom de l'équipe doit apparaître dans la section invitations
    assert_select "h2", text: /Invitations en attente/
    assert_select "form[action='#{accept_team_invitation_path(@team_one, @pending)}']"
    assert_select "form[action='#{refuse_team_invitation_path(@team_one, @pending)}']"
  end

  test "user without invitations sees only their teams on index" do
    sign_in @member

    get teams_path

    assert_response :success
    # Pas de section invitations en attente pour un membre actif sans invitation
    assert_select "h2", text: /Invitations en attente/, count: 0
  end
end
