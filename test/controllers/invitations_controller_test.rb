require "test_helper"

class InvitationsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :teams, :memberships, :team_invitations

  setup do
    @organizer   = users(:organizer)
    @member      = users(:member)
    @non_member  = users(:non_member)
    @team_one    = teams(:team_one)
    @pending     = team_invitations(:pending_invitation)
    @accepted    = team_invitations(:accepted_invitation)
    @refused     = team_invitations(:refused_invitation)
  end

  # ============================================================
  # US1 – T010: Accept / Refuse (autorisation, idempotence)
  # ============================================================

  test "unauthenticated user cannot accept an invitation" do
    patch accept_team_invitation_path(@team_one, @pending)
    assert_redirected_to new_user_session_path
  end

  test "unauthenticated user cannot refuse an invitation" do
    patch refuse_team_invitation_path(@team_one, @pending)
    assert_redirected_to new_user_session_path
  end

  test "invitee can accept a pending invitation" do
    sign_in @non_member

    assert_difference("Membership.count", 1) do
      assert_difference("TeamInvitation.where(status: :accepted).count", 1) do
        patch accept_team_invitation_path(@team_one, @pending)
      end
    end

    assert_redirected_to teams_path
    assert_equal I18n.t("invitations.accept.success"), flash[:notice]
    assert @pending.reload.accepted?
    assert @pending.reload.responded_at.present?
    assert @team_one.members.reload.include?(@non_member)
  end

  test "invitee can refuse a pending invitation" do
    sign_in @non_member

    assert_no_difference("Membership.count") do
      patch refuse_team_invitation_path(@team_one, @pending)
    end

    assert_redirected_to teams_path
    assert_equal I18n.t("invitations.refuse.success"), flash[:notice]
    assert @pending.reload.refused?
    assert @pending.reload.responded_at.present?
    assert_not @team_one.members.reload.include?(@non_member)
  end

  test "non-owner cannot accept another user invitation" do
    sign_in @member

    assert_no_difference("Membership.count") do
      patch accept_team_invitation_path(@team_one, @pending)
    end

    assert_redirected_to teams_path
    assert_equal I18n.t("invitations.accept.forbidden"), flash[:alert]
    assert @pending.reload.pending?
  end

  test "non-owner cannot refuse another user invitation" do
    sign_in @member

    patch refuse_team_invitation_path(@team_one, @pending)

    assert_redirected_to teams_path
    assert_equal I18n.t("invitations.refuse.forbidden"), flash[:alert]
    assert @pending.reload.pending?
  end

  test "already accepted invitation cannot be accepted again" do
    sign_in @member

    assert_no_difference("Membership.count") do
      patch accept_team_invitation_path(teams(:team_two), @accepted)
    end

    assert_redirected_to teams_path
    assert_equal I18n.t("invitations.accept.already_processed"), flash[:alert]
  end

  test "already refused invitation cannot be refused again" do
    sign_in @member

    patch refuse_team_invitation_path(teams(:team_three), @refused)

    assert_redirected_to teams_path
    assert_equal I18n.t("invitations.refuse.already_processed"), flash[:alert]
  end

  # ============================================================
  # T033: Multi-team — accepter une invitation n'affecte pas les autres invitations pending
  # ============================================================

  test "accepting one invitation does not affect other pending invitations from other teams" do
    other_team = Team.create!(name: "Autre Équipe", organizer: @organizer)
    other_invitation = TeamInvitation.create!(
      team: other_team,
      invited_user: @non_member,
      invited_by: @organizer,
      status: :pending
    )

    sign_in @non_member

    patch accept_team_invitation_path(@team_one, @pending)

    assert @pending.reload.accepted?
    assert other_invitation.reload.pending?,
      "L'invitation de l'autre équipe ne doit pas être affectée"
  end

  # ============================================================
  # US2 – T017: Create invitation (organisateur-only, doublon, membre déjà actif)
  # ============================================================

  test "unauthenticated user cannot create an invitation" do
    assert_no_difference("TeamInvitation.count") do
      post team_invitations_path(@team_one), params: { email: @non_member.email }
    end
    assert_redirected_to new_user_session_path
  end

  test "organizer can invite a user who is not yet a member" do
    # Utiliser un utilisateur sans invitation pending existante vers team_one
    new_user = User.create!(name: "Invité Test", email: "invite_test_#{SecureRandom.hex(4)}@example.com", password: "password123")
    sign_in @organizer

    assert_difference("TeamInvitation.count", 1) do
      post team_invitations_path(@team_one), params: { email: new_user.email }
    end

    assert_redirected_to team_path(@team_one)
    assert_equal I18n.t("invitations.create.success"), flash[:notice]

    invitation = TeamInvitation.last
    assert invitation.pending?
    assert_equal new_user,   invitation.invited_user
    assert_equal @organizer, invitation.invited_by
  end

  test "non-organizer member cannot create an invitation" do
    sign_in @member

    assert_no_difference("TeamInvitation.count") do
      post team_invitations_path(@team_one), params: { email: @non_member.email }
    end

    assert_redirected_to team_path(@team_one)
    assert_equal I18n.t("authorization.organizer_only"), flash[:alert]
  end

  test "organizer cannot invite an already active member" do
    sign_in @organizer

    assert_no_difference("TeamInvitation.count") do
      post team_invitations_path(@team_one), params: { email: @member.email }
    end

    assert_redirected_to team_path(@team_one)
    assert_equal I18n.t("invitations.create.already_member"), flash[:alert]
  end

  test "organizer cannot send a duplicate pending invitation" do
    existing = team_invitations(:pending_invitation)
    sign_in @organizer

    assert_no_difference("TeamInvitation.count") do
      post team_invitations_path(@team_one), params: { email: @non_member.email }
    end

    assert_redirected_to team_path(@team_one)
    assert_equal I18n.t("invitations.create.already_invited"), flash[:alert]
  end

  test "organizer gets alert when email is not found" do
    sign_in @organizer

    assert_no_difference("TeamInvitation.count") do
      post team_invitations_path(@team_one), params: { email: "nobody@example.com" }
    end

    assert_redirected_to team_path(@team_one)
    assert_equal I18n.t("invitations.create.not_found"), flash[:alert]
  end

  # ============================================================
  # T034: Pas d'expiration automatique — une invitation reste pending sans réponse explicite
  # ============================================================

  test "pending invitation stays pending without explicit response" do
    sign_in @organizer

    post team_invitations_path(@team_one), params: { email: @non_member.email }

    # L'invitation existante dans les fixtures est pending — pas de changement si non répondue
    assert @pending.reload.pending?,
      "L'invitation existante ne doit pas expirer automatiquement"
  end

  # ============================================================
  # US2 – T018: Flux d'ajout membre memberships ne crée plus d'adhésion directe
  # ============================================================

  test "organizer adding a member via memberships path now creates invitation, not direct membership" do
    new_user = User.create!(name: "Invité BIS", email: "invite_bis_#{SecureRandom.hex(4)}@example.com", password: "password123")
    sign_in @organizer

    # Ce comportement est validé dans memberships_controller_test.rb (T018)
    # Ici on vérifie que la route invitation crée bien une invitation
    assert_difference("TeamInvitation.count", 1) do
      assert_no_difference("Membership.count") do
        post team_invitations_path(@team_one), params: { email: new_user.email }
      end
    end
  end
end
