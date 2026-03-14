class GamesController < ApplicationController
  before_action :set_team, only: [ :index, :new, :create ]
  before_action :set_game, only: [ :show, :start_guessing, :finish, :destroy ]
  before_action :authorize_team_member!, only: [ :show ]
  # Feature 012: progression actions open to all team members (US1)
  before_action :authorize_game_team_member!, only: [ :start_guessing, :finish ]
  # Cancellation remains organizer-only (US2)
  before_action :authorize_organizer_for_game!, only: [ :destroy ]

  def index
    @games = @team.games.order(created_at: :desc)
  end

  def new
    @game = @team.games.build
  end

  def create
    created = false
    max_retries = 3
    retry_delays_ms = [ 10, 25, 50 ]
    attempt = 0

    begin
      @team.with_lock do
        @game = @team.games.build
        @game.team_game_number = Game.next_team_game_number_for(@team)
        created = @game.save
      end
    rescue ActiveRecord::RecordNotUnique
      attempt += 1
      if attempt < max_retries
        sleep(retry_delays_ms[attempt - 1] / 1000.0)
        retry
      end
      @game ||= @team.games.build
      @game.errors.add(:base, "Impossible d'assigner un numéro de partie unique. Veuillez réessayer.")
    end

    if created
      redirect_to @game, notice: I18n.t("games.create.success")
    else
      flash.now[:alert] = @game.errors.full_messages.to_sentence if @game.errors.any?
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @team = @game.team
    @proposals = @game.proposals.includes(:player)
    @my_proposal = @proposals.find_by(player: current_user)
    @players_with_proposals = @proposals.map(&:player)
    @members = @team.members

    # Calcul des joueurs ayant soumis toutes leurs devinettes (phase guessing)
    if @game.guessing?
      expected_guesses = @proposals.count - 1
      guess_counts = Guess.joins(:proposal)
                          .where(proposals: { game_id: @game.id })
                          .group(:player_id)
                          .count
      @players_with_guesses = @players_with_proposals.select do |player|
        (guess_counts[player.id] || 0) == expected_guesses
      end
    end
  end

  def start_guessing
    if @game.proposals.count < 2
      redirect_to @game, alert: "Au moins 2 joueurs doivent avoir soumis une proposition pour passer aux devinettes."
      return
    end

    @game.with_lock { @game.start_guessing! }
    redirect_to @game, notice: I18n.t("games.start_guessing.success")
  rescue Game::InvalidTransitionError
    redirect_to @game, alert: I18n.t("games.transition.conflict")
  end

  def finish
    @game.with_lock { @game.finish! }
    redirect_to game_results_path(@game), notice: I18n.t("games.finish.success")
  rescue Game::InvalidTransitionError
    redirect_to @game, alert: I18n.t("games.transition.conflict")
  end

  def destroy
    @team = @game.team

    unless @game.can_cancel?
      redirect_to @game, alert: I18n.t("games.destroy.cannot_cancel_finished")
      return
    end

    ActiveRecord::Base.transaction do
      @game.destroy!
    end

    redirect_to team_games_path(@team), notice: I18n.t("games.destroy.success")
  rescue ActiveRecord::RecordNotDestroyed
    redirect_to @game, alert: I18n.t("games.destroy.error")
  end

  private

  def set_team
    @team = current_user.teams.find_by!(public_id: params[:team_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to teams_path, alert: "Équipe introuvable ou accès non autorisé."
  end

  def set_game
    @game = Game.find_by!(public_id: params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to teams_path, alert: "Partie introuvable."
  end

  # Verify current user is a member of the game's team (used for show)
  def authorize_team_member!
    authorize_team_member_on!(@game.team)
  end

  # Verify current user is a member of the game's team (used for progression actions)
  # Delegates to shared ApplicationController helper (feature 012)
  def authorize_game_team_member!
    authorize_team_member_on!(@game.team)
  end

  # Verify current user is the organizer of the game's team (cancellation only)
  def authorize_organizer_for_game!
    team = @team || @game&.team
    authorize_team_organizer_on!(team) if team
  end
end
