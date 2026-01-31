class Game < ApplicationRecord
  # Enum for game status
  enum :status, { collecting: 0, guessing: 1, finished: 2 }, default: :collecting

  # Associations
  belongs_to :team
  has_many :proposals, dependent: :destroy
  has_many :players, through: :proposals, source: :player
  has_many :guesses, through: :proposals

  # Validations
  validates :status, presence: true

  # State transitions
  def start_guessing!
    raise InvalidTransitionError, "La partie doit être en phase de collecte" unless collecting?
    raise InvalidTransitionError, "Au moins 2 joueurs doivent avoir soumis une proposition" if proposals.count < 2

    update!(status: :guessing, started_at: Time.current)
  end

  def finish!
    raise InvalidTransitionError, "La partie doit être en phase de devinettes" unless guessing?

    update!(status: :finished, finished_at: Time.current)
  end

  # Score calculation
  def calculate_scores
    proposals.includes(:player, :guesses).map do |proposal|
      proposal.guesses.map do |guess|
        {
          player: guess.player,
          correct: guess.guessed_author_id == proposal.player_id
        }
      end
    end.flatten.group_by { |r| r[:player] }.map do |player, results|
      { player: player, score: results.count { |r| r[:correct] } }
    end.sort_by { |r| -r[:score] }
  end

  def ranking
    scores = calculate_scores
    rank = 0
    previous_score = nil

    scores.each_with_index do |entry, index|
      if entry[:score] != previous_score
        rank = index + 1
        previous_score = entry[:score]
      end
      entry[:rank] = rank
    end

    scores
  end

  # Custom exception for invalid state transitions
  class InvalidTransitionError < StandardError; end
end
