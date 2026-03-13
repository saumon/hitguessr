class ResultsController < ApplicationController
  before_action :set_game
  before_action :authorize_team_member!
  before_action :authorize_finished!

  def show
    @team = @game.team
    @ranking = @game.ranking
    @proposals = @game.proposals.includes(:player, guesses: [ :player, :guessed_author ])
  end

  private

  def set_game
    @game = Game.find_by!(public_id: params[:game_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to teams_path, alert: "Partie introuvable."
  end

  def authorize_team_member!
    unless @game.team.members.include?(current_user)
      redirect_to teams_path, alert: "Vous n'êtes pas membre de cette équipe."
    end
  end

  def authorize_finished!
    unless @game.finished?
      redirect_to game_path(@game), alert: "La partie n'est pas encore terminée."
    end
  end
end
