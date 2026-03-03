class InvitationsController < ApplicationController
  before_action :set_team
  before_action :authorize_organizer!, only: [ :create ]
  before_action :set_invitation, only: [ :accept, :refuse ]

  # POST /teams/:team_id/invitations
  def create
    email = params[:email]&.strip&.downcase
    user  = User.find_by(email: email)

    if user.nil?
      redirect_to @team, alert: t("invitations.create.not_found")
      return
    end

    if @team.members.include?(user)
      redirect_to @team, alert: t("invitations.create.already_member")
      return
    end

    if @team.team_invitations.pending_only.exists?(invited_user: user)
      redirect_to @team, alert: t("invitations.create.already_invited")
      return
    end

    invitation = @team.team_invitations.build(
      invited_user: user,
      invited_by:   current_user,
      status:       :pending
    )

    if invitation.save
      redirect_to @team, notice: t("invitations.create.success")
    else
      redirect_to @team, alert: invitation.errors.full_messages.to_sentence
    end
  end

  # PATCH /teams/:team_id/invitations/:id/accept
  def accept
    unless @invitation.invited_user == current_user
      redirect_to teams_path, alert: t("invitations.accept.forbidden")
      return
    end

    unless @invitation.pending?
      redirect_to teams_path, alert: t("invitations.accept.already_processed")
      return
    end

    if @invitation.accept!
      redirect_to teams_path, notice: t("invitations.accept.success")
    else
      redirect_to teams_path, alert: t("invitations.accept.already_processed")
    end
  end

  # PATCH /teams/:team_id/invitations/:id/refuse
  def refuse
    unless @invitation.invited_user == current_user
      redirect_to teams_path, alert: t("invitations.refuse.forbidden")
      return
    end

    unless @invitation.pending?
      redirect_to teams_path, alert: t("invitations.refuse.already_processed")
      return
    end

    if @invitation.refuse!
      redirect_to teams_path, notice: t("invitations.refuse.success")
    else
      redirect_to teams_path, alert: t("invitations.refuse.already_processed")
    end
  end

  private

  def set_team
    @team = Team.find(params[:team_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to teams_path, alert: t("invitations.not_found")
  end

  def set_invitation
    @invitation = @team.team_invitations.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to teams_path, alert: t("invitations.not_found")
  end

  def authorize_organizer!
    authorize_team_organizer_on!(@team)
  end
end
