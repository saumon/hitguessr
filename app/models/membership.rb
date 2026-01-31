class Membership < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :team

  # Validations
  validates :user_id, uniqueness: { scope: :team_id, message: "est déjà membre de cette équipe" }
end
