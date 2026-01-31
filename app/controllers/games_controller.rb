class GamesController < ApplicationController
  before_action :set_team, only: [ :index, :new, :create ]
  before_action :set_game, only: [ :show, :start_guessing, :finish ]
  before_action :authorize_team_member!, only: [ :show ]
  before_action :authorize_organizer_for_game!, only: [ :new, :create, :start_guessing, :finish ]

  def index
    @games = @team.games.order(created_at: :desc)
  end

  def new
    @game = @team.games.build
  end

  def create
    @game = @team.games.build

    if @game.save
      redirect_to @game, notice: "Partie lancée ! Les joueurs peuvent maintenant soumettre leurs propositions."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @team = @game.team
    @proposals = @game.proposals.includes(:player)
    @my_proposal = @proposals.find_by(player: current_user)
    @players_with_proposals = @proposals.map(&:player)
    @members = @team.members
  end

  def start_guessing
    if @game.proposals.count < 2
      redirect_to @game, alert: "Au moins 2 joueurs doivent avoir soumis une proposition pour passer aux devinettes."
      return
    end

    @game.start_guessing!
    redirect_to @game, notice: "Phase de devinettes lancée !"
  rescue Game::InvalidTransitionError => e
    redirect_to @game, alert: e.message
  end

  def finish
    @game.finish!
    redirect_to game_results_path(@game), notice: "Partie terminée ! Découvrez les résultats."
  rescue Game::InvalidTransitionError => e
    redirect_to @game, alert: e.message
  end

  private

  def set_team
    @team = current_user.teams.find(params[:team_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to teams_path, alert: "Équipe introuvable ou accès non autorisé."
  end

  def set_game
    @game = Game.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to teams_path, alert: "Partie introuvable."
  end

  def authorize_team_member!
    unless @game.team.members.include?(current_user)
      redirect_to teams_path, alert: "Vous n'êtes pas membre de cette équipe."
    end
  end

  def authorize_organizer_for_game!
    team = @team || @game&.team
    unless team&.organizer == current_user
      redirect_to (team ? team : teams_path), alert: "Seul l'organisateur peut effectuer cette action."
    end
  end
end
