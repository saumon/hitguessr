class ProposalsController < ApplicationController
  before_action :set_game
  before_action :authorize_team_member!
  before_action :authorize_collecting_phase!, only: [ :new, :create ]
  before_action :set_proposal, only: [ :show ]
  before_action :authorize_owner!, only: [ :show ]

  def new
    if @game.proposals.exists?(player: current_user)
      redirect_to game_path(@game), alert: "Vous avez déjà soumis une proposition pour cette partie."
      return
    end

    @proposal = @game.proposals.build
  end

  def create
    if @game.proposals.exists?(player: current_user)
      redirect_to game_path(@game), alert: "Vous avez déjà soumis une proposition pour cette partie."
      return
    end

    @proposal = @game.proposals.build(proposal_params)
    @proposal.player = current_user

    if @proposal.save
      redirect_to game_path(@game), notice: "Proposition soumise avec succès !"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    # Only the owner can see their proposal
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to teams_path, alert: "Partie introuvable."
  end

  def set_proposal
    @proposal = @game.proposals.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to game_path(@game), alert: "Proposition introuvable."
  end

  def authorize_team_member!
    unless @game.team.members.include?(current_user)
      redirect_to teams_path, alert: "Vous n'êtes pas membre de cette équipe."
    end
  end

  def authorize_collecting_phase!
    unless @game.collecting?
      redirect_to game_path(@game), alert: "La phase de collecte est terminée."
    end
  end

  def authorize_owner!
    unless @proposal.player == current_user
      redirect_to game_path(@game), alert: "Vous ne pouvez voir que votre propre proposition."
    end
  end

  def proposal_params
    params.require(:proposal).permit(:url)
  end
end
