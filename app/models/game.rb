class Game < ApplicationRecord
  include PublicId

  MINIMUM_TEAM_MEMBERS = 3

  def self.public_id_prefix
    "gm"
  end

  # Enum for game status
  enum :status, { collecting: 0, guessing: 1, finished: 2 }, default: :collecting

  # Scopes
  scope :active, -> { where(status: [ :collecting, :guessing ]) }

  # Associations
  belongs_to :team
  has_many :proposals, dependent: :destroy
  has_many :players, through: :proposals, source: :player
  has_many :guesses, through: :proposals

  # Validations
  validates :status, presence: true
  validate :only_one_active_game_per_team, on: :create
  validate :minimum_team_members_required, on: :create

  # State transitions
  def start_guessing!
    raise InvalidTransitionError, "La partie doit être en phase de collecte" unless collecting?
    raise InvalidTransitionError, "Au moins 2 joueurs doivent avoir soumis une proposition" if proposals.count < 2

    assign_guess_order!
    update!(status: :guessing, started_at: Time.current)
  end

  # Lecture ordonnée des propositions pour la phase de devinette.
  # L'ordre est figé lors de l'appel à start_guessing! et stable entre reloads.
  # Fallback id ASC pour garantir un ordre déterministe en cas d'égalité.
  def ordered_proposals_for_guessing
    proposals.order(:guess_order_position, :id)
  end

  def finish!
    raise InvalidTransitionError, "La partie doit être en phase de devinettes" unless guessing?

    update!(status: :finished, finished_at: Time.current)
  end

  # Auto-progression detection methods
  def all_members_submitted?
    proposals.count >= team.members.count && proposals.count >= 2
  end

  def expected_guesses_count
    n = proposals.count
    n * (n - 1)
  end

  def all_guesses_submitted?
    guesses.count >= expected_guesses_count
  end

  # Auto-progression triggers with locking for concurrency safety
  def try_auto_progress_to_guessing!
    with_lock do
      return unless collecting?
      return unless all_members_submitted?
      start_guessing!
    end
  end

  def try_auto_finish!
    with_lock do
      return unless guessing?
      return unless all_guesses_submitted?
      finish!
    end
  end

  # Check if the game can be cancelled (only active games)
  def can_cancel?
    collecting? || guessing?
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

  private

  # Assigne un ordre de devinette aléatoire (positions 1..N) aux propositions,
  # uniquement si elles ne sont pas encore ordonnées (idempotence).
  # Garantit que le même ordre est utilisé pour tous les joueurs de la manche.
  def assign_guess_order!
    unordered = proposals.where(guess_order_position: nil).to_a
    return if unordered.empty?

    unordered.shuffle.each_with_index do |proposal, index|
      proposal.update_column(:guess_order_position, index + 1)
    end
  end

  def only_one_active_game_per_team
    if team&.has_active_game?
      errors.add(:base, "Une partie est déjà en cours pour cette équipe. Terminez-la avant d'en lancer une nouvelle.")
    end
  end

  def minimum_team_members_required
    return if team.blank?
    return if team.eligible_to_start_game?(MINIMUM_TEAM_MEMBERS)

    errors.add(:base, I18n.t("games.create.minimum_members_required", count: MINIMUM_TEAM_MEMBERS))
  end
end
