class ProposalsController < ApplicationController
  before_action :set_game
  before_action :authorize_team_member!
  # Phase guard for GET only — create checks at submission time for race-condition safety (US3)
  before_action :authorize_collecting_phase!, only: [ :new ]
  before_action :set_proposal, only: [ :show ]
  before_action :authorize_owner!, only: [ :show ]

  def new
    # Show form even if player already has a proposal (editing flow)
    @existing_proposal = @game.proposals.find_by(player: current_user)
    # Pre-fill form with current URL if editing
    @proposal = @game.proposals.build(url: @existing_proposal&.url)
  end

  def create
    # Reload game to evaluate phase at the exact moment of submission (US3 — race condition guard, T026)
    @game.reload

    unless @game.collecting?
      redirect_to game_path(@game), alert: "La phase de collecte est terminée, votre proposition est verrouillée."
      return
    end

    # Upsert: find existing proposal (if any) and update it, or build a new one (T014)
    existing_proposal = @game.proposals.find_by(player: current_user)
    is_new_record = existing_proposal.nil?
    target = existing_proposal || @game.proposals.build(player: current_user)
    target.assign_attributes(proposal_params)

    if target.save
      # Check if game automatically progressed to guessing phase after save
      @game.reload
      notice_message = if @game.guessing?
        "Proposition soumise avec succès ! Tous les joueurs ont soumis, la partie passe automatiquement en phase de devinettes."
      elsif is_new_record
        "Proposition soumise avec succès !"
      else
        "Proposition modifiée avec succès !"
      end
      redirect_to game_path(@game), notice: notice_message
    else
      # Always render with a new (unsaved) proposal so form_with generates POST to create endpoint
      @existing_proposal = existing_proposal
      @proposal = @game.proposals.build(url: target.url)
      target.errors.each { |error| @proposal.errors.add(error.attribute, error.message) }
      render :new, status: :unprocessable_entity
    end
  end

  def show
    # Only the owner can see their proposal
  end

  private

  def set_game
    @game = Game.find_by!(public_id: params[:game_id])
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
