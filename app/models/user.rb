class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

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

  # Toggle-aware confirmation (T024, T032):
  # When the feature toggle is disabled (development default), no confirmation email is sent
  # and unconfirmed users can sign in normally (via active_for_authentication? inheriting this).
  # When enabled, standard Devise Confirmable enforcement applies.
  def confirmation_required?
    Rails.application.config.x.account_email_confirmation_enabled
  end

  # Audit log: emit a structured event when Devise blocks a sign-in due to unconfirmed status (T031).
  def inactive_message
    msg = super
    if msg == :unconfirmed
      Rails.logger.warn "[confirmation] event=sign_in_blocked_unconfirmed email=#{email}"
    end
    msg
  end
end
