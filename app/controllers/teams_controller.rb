class TeamsController < ApplicationController
  before_action :set_team, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_organizer!, only: [ :edit, :update, :destroy ]

  def index
    @teams = current_user.teams.includes(:organizer, :members)
  end

  def show
    @members = @team.members
    @games = @team.games.order(created_at: :desc)
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)
    @team.organizer = current_user

    if @team.save
      redirect_to @team, notice: "Équipe créée avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @team.update(team_params)
      redirect_to @team, notice: "Équipe mise à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_path, notice: "Équipe supprimée."
  end

  private

  def set_team
    @team = current_user.teams.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to teams_path, alert: "Équipe introuvable ou accès non autorisé."
  end

  def team_params
    params.require(:team).permit(:name)
  end

  def authorize_organizer!
    unless @team.organizer == current_user
      redirect_to @team, alert: "Seul l'organisateur peut effectuer cette action."
    end
  end
end
