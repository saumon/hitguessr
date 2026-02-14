class Proposal < ApplicationRecord
  # Associations
  belongs_to :game
  belongs_to :player, class_name: "User", inverse_of: :proposals
  has_many :guesses, dependent: :destroy

  # Validations
  validates :url, presence: true
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "doit être une URL valide (http/https)" }, if: -> { url.present? }
  validates :url, uniqueness: { scope: :game_id, message: "a déjà été proposée dans cette partie" }
  validates :player_id, uniqueness: { scope: :game_id, message: "a déjà soumis une proposition pour cette partie" }
  validate :game_must_be_collecting, on: :create

  # Callbacks
  before_validation :normalize_url
  after_create_commit :try_auto_progress_game

  private

  def try_auto_progress_game
    game.try_auto_progress_to_guessing!
  end

  def normalize_url
    return if url.blank?

    normalized = url.strip
    normalized = normalized.chomp("/") # Remove trailing slash
    normalized = normalized.gsub(/#.*$/, "") # Remove fragment
    self.url = normalized
  end

  def game_must_be_collecting
    return if game.nil?

    errors.add(:game, "n'accepte plus de propositions") unless game.collecting?
  end
end
