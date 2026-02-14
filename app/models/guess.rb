class Guess < ApplicationRecord
  # Associations
  belongs_to :player, class_name: "User", inverse_of: :guesses
  belongs_to :proposal
  belongs_to :guessed_author, class_name: "User"

  # Validations
  validates :player_id, uniqueness: { scope: :proposal_id, message: "a déjà deviné pour cette proposition" }
  validate :guessed_author_must_be_team_player
  validate :game_must_be_guessing, on: :create
  validate :cannot_guess_own_proposal

  # Callbacks
  after_create_commit :try_auto_finish_game

  private

  def try_auto_finish_game
    proposal.game.try_auto_finish!
  end

  def guessed_author_must_be_team_player
    return if proposal.nil? || guessed_author.nil?

    game = proposal.game
    player_ids = game.proposals.pluck(:player_id)

    unless player_ids.include?(guessed_author_id)
      errors.add(:guessed_author, "doit être un joueur ayant soumis une proposition")
    end
  end

  def game_must_be_guessing
    return if proposal.nil?

    errors.add(:proposal, "la partie n'est pas en phase de devinettes") unless proposal.game.guessing?
  end

  def cannot_guess_own_proposal
    return if proposal.nil? || player.nil?

    if proposal.player_id == player_id
      errors.add(:base, "Vous ne pouvez pas deviner votre propre proposition")
    end
  end
end
