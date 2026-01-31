class MembershipsController < ApplicationController
  before_action :set_team
  before_action :authorize_organizer!

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

  private

  def set_team
    @team = current_user.teams.find(params[:team_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to teams_path, alert: "Équipe introuvable ou accès non autorisé."
  end

  def authorize_organizer!
    unless @team.organizer == current_user
      redirect_to @team, alert: "Seul l'organisateur peut gérer les membres."
    end
  end
end
