class TeamsController < ApplicationController
  before_action :set_team, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_organizer!, only: [ :edit, :update, :destroy ]

  def index
    @teams = current_user.teams.includes(:organizer, :members)
    @pending_invitations = current_user.received_invitations
                                       .pending_only
                                       .includes(team: [ :organizer, :members ], invited_by: [])
  end

  def show
    @members = @team.members.includes(:memberships)
    @games = @team.games.order(created_at: :desc)
    @leaderboard = @team.leaderboard

    is_member_or_organizer = @team.members.include?(current_user) || @team.organizer == current_user

    # US3 – invitations en attente visibles aux membres actifs + organisateur (FR-016)
    # Pour un invité non-membre, seule sa propre invitation est visible
    @pending_invitations = if is_member_or_organizer
                             @team.team_invitations.pending_only.includes(:invited_user, :invited_by)
    else
                             @team.team_invitations.pending_only.for_user(current_user).includes(:invited_user, :invited_by)
    end

    # US1 – invitations reçues par l'utilisateur courant (pour Accepter/Refuser)
    @my_pending_invitations = @team.team_invitations.pending_only.for_user(current_user)
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
    @team = current_user.teams.find_by(public_id: params[:id])

    # Permettre aussi l'accès aux utilisateurs avec une invitation en attente
    if @team.nil?
      @team = Team
                .joins(:team_invitations)
                .where(team_invitations: { invited_user_id: current_user.id, status: TeamInvitation.statuses[:pending] })
                .find_by(public_id: params[:id])
    end

    redirect_to teams_path, alert: "Équipe introuvable ou accès non autorisé." if @team.nil?
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
