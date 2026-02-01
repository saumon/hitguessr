class Team < ApplicationRecord
  # Associations
  belongs_to :organizer, class_name: "User", inverse_of: :organized_teams
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :games, dependent: :destroy

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

  private

  def add_organizer_as_member
    memberships.create!(user: organizer)
  end
end
