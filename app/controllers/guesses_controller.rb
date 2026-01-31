class GuessesController < ApplicationController
  before_action :set_game
  before_action :authorize_team_member!
  before_action :authorize_guessing_phase!
  before_action :authorize_has_proposal!

  def new
    # Check if already submitted guesses
    my_guesses = current_user.guesses.joins(:proposal).where(proposals: { game_id: @game.id })
    if my_guesses.exists?
      redirect_to game_path(@game), alert: "Vous avez déjà soumis vos devinettes."
      return
    end

    @proposals = @game.proposals.where.not(player: current_user).includes(:player)
    @players = @game.proposals.includes(:player).map(&:player)
  end

  def create
    # Check if already submitted guesses
    my_guesses = current_user.guesses.joins(:proposal).where(proposals: { game_id: @game.id })
    if my_guesses.exists?
      redirect_to game_path(@game), alert: "Vous avez déjà soumis vos devinettes."
      return
    end

    proposals_to_guess = @game.proposals.where.not(player: current_user)
    guesses_params = params[:guesses] || {}

    # Validate all proposals are guessed
    if guesses_params.keys.map(&:to_i).sort != proposals_to_guess.pluck(:id).sort
      redirect_to new_game_guess_path(@game), alert: "Vous devez deviner l'auteur de chaque proposition."
      return
    end

    # Create all guesses in a transaction
    ActiveRecord::Base.transaction do
      guesses_params.each do |proposal_id, guessed_author_id|
        proposal = proposals_to_guess.find(proposal_id)
        guess = Guess.new(
          player: current_user,
          proposal: proposal,
          guessed_author_id: guessed_author_id
        )

        unless guess.save
          raise ActiveRecord::Rollback
          redirect_to new_game_guess_path(@game), alert: "Erreur lors de la sauvegarde: #{guess.errors.full_messages.join(', ')}"
          return
        end
      end
    end

    redirect_to game_path(@game), notice: "Devinettes soumises avec succès !"
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to teams_path, alert: "Partie introuvable."
  end

  def authorize_team_member!
    unless @game.team.members.include?(current_user)
      redirect_to teams_path, alert: "Vous n'êtes pas membre de cette équipe."
    end
  end

  def authorize_guessing_phase!
    unless @game.guessing?
      redirect_to game_path(@game), alert: "La partie n'est pas en phase de devinettes."
    end
  end

  def authorize_has_proposal!
    unless @game.proposals.exists?(player: current_user)
      redirect_to game_path(@game), alert: "Vous n'avez pas soumis de proposition pour cette partie."
    end
  end
end
