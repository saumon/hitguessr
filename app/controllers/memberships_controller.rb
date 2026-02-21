class MembershipsController < ApplicationController
  before_action :set_team, only: [ :create, :destroy ]
  before_action :authorize_organizer!, only: [ :create, :destroy ]
  before_action :set_team_for_leave, only: [ :leave ]

  def create
    user = User.find_by(email: params[:email]&.strip&.downcase)

    if user.nil?
      redirect_to @team, alert: "Aucun utilisateur trouvé avec cet email."
      return
    end

    if @team.members.include?(user)
      redirect_to @team, alert: "#{user.name} est déjà membre de cette équipe."
      return
    end

    membership = @team.memberships.build(user: user)
    if membership.save
      redirect_to @team, notice: "#{user.name} a été ajouté à l'équipe."
    else
      redirect_to @team, alert: "Impossible d'ajouter ce membre."
    end
  end

  def destroy
    membership = @team.memberships.find(params[:id])

    if membership.user == @team.organizer
      redirect_to @team, alert: "L'organisateur ne peut pas être retiré de l'équipe."
      return
    end

    membership.destroy
    redirect_to @team, notice: "#{membership.user.name} a été retiré de l'équipe."
  end

  def leave
    return if performed?

    if @team.organizer_id == current_user.id
      redirect_to @team, alert: I18n.t("memberships.leave.organizer_forbidden")
      return
    end

    if @team.has_active_game?
      redirect_to @team, alert: I18n.t("memberships.leave.active_game_forbidden")
      return
    end

    membership = @team.memberships.find_by(user_id: current_user.id)

    if membership.nil?
      redirect_to teams_path, notice: I18n.t("memberships.leave.already_left")
      return
    end

    membership.destroy
    redirect_to teams_path, notice: I18n.t("memberships.leave.success")
  end

  private

  def set_team
    @team = current_user.teams.find(params[:team_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to teams_path, alert: "Équipe introuvable ou accès non autorisé."
  end

  def set_team_for_leave
    @team = Team.find(params[:team_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to teams_path, alert: I18n.t("memberships.leave.unauthorized")
  end

  def authorize_organizer!
    unless @team.organizer == current_user
      redirect_to @team, alert: "Seul l'organisateur peut gérer les membres."
    end
  end
end
