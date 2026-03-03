class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :organized_teams, class_name: "Team", foreign_key: :organizer_id, dependent: :destroy, inverse_of: :organizer
  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships
  has_many :proposals, foreign_key: :player_id, dependent: :destroy, inverse_of: :player
  has_many :guesses, foreign_key: :player_id, dependent: :destroy, inverse_of: :player
  has_many :received_invitations, class_name: "TeamInvitation", foreign_key: :invited_user_id, dependent: :destroy
  has_many :sent_invitations,     class_name: "TeamInvitation", foreign_key: :invited_by_id,   dependent: :destroy

  # Validations
  validates :name, presence: true
end
