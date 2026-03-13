class Team < ApplicationRecord
  include PublicId

  def self.public_id_prefix
    "tm"
  end

  # Associations
  belongs_to :organizer, class_name: "User", inverse_of: :organized_teams
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :games, dependent: :destroy
  has_many :team_invitations, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }

  # Callbacks
  after_create :add_organizer_as_member

  # Active game helpers
  def active_game
    games.active.first
  end

  def has_active_game?
    games.active.exists?
  end

  def active_confirmed_members_count
    memberships.count
  end

  def eligible_to_start_game?(minimum_members = Game::MINIMUM_TEAM_MEMBERS)
    active_confirmed_members_count >= minimum_members
  end

  # Leaderboard: cumulative scores across all finished games
  # Returns array of { player:, score:, rank: } sorted by score descending
  # Players with equal scores share the same rank (ex aequo)
  def leaderboard
    # Aggregate scores from all finished games
    scores_by_player = Hash.new(0)

    games.finished.each do |game|
      game.calculate_scores.each do |entry|
        scores_by_player[entry[:player]] += entry[:score]
      end
    end

    # Convert to array and sort by score descending
    sorted_scores = scores_by_player.map do |player, score|
      { player: player, score: score }
    end.sort_by { |entry| -entry[:score] }

    # Assign ranks with ex aequo handling (same pattern as Game#ranking)
    rank = 0
    previous_score = nil

    sorted_scores.each_with_index do |entry, index|
      if entry[:score] != previous_score
        rank = index + 1
        previous_score = entry[:score]
      end
      entry[:rank] = rank
    end

    sorted_scores
  end

  private

  def add_organizer_as_member
    memberships.create!(user: organizer)
  end
end
