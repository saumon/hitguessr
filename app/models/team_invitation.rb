class TeamInvitation < ApplicationRecord
  # Enums
  enum :status, { pending: 0, accepted: 1, refused: 2 }, default: :pending

  # Associations
  belongs_to :team
  belongs_to :invited_user, class_name: "User"
  belongs_to :invited_by,   class_name: "User"

  # Validations
  validates :status, presence: true
  validate  :invited_user_not_already_active_member, on: :create

  # responded_at requis dès que l'invitation est traitée
  validates :responded_at, presence: true, unless: :pending?

  # Scopes
  scope :pending_only, -> { where(status: :pending) }
  scope :for_user,     ->(user) { where(invited_user: user) }
  scope :for_team,     ->(team) { where(team: team) }

  # Transition atomique : accepted uniquement depuis pending (première réponse gagnante)
  # Retourne true si la mise à jour a réussi, false sinon (idempotent).
  def accept!(membership_attrs = {})
    TeamInvitation.transaction do
      rows = TeamInvitation
               .where(id: id, status: TeamInvitation.statuses[:pending])
               .update_all(status: TeamInvitation.statuses[:accepted], responded_at: Time.current, updated_at: Time.current)

      if rows == 1
        reload
        team.memberships.find_or_create_by!(user: invited_user)
        true
      else
        false
      end
    end
  end

  # Transition atomique : refused uniquement depuis pending
  def refuse!
    rows = TeamInvitation
             .where(id: id, status: TeamInvitation.statuses[:pending])
             .update_all(status: TeamInvitation.statuses[:refused], responded_at: Time.current, updated_at: Time.current)
    reload
    rows == 1
  end

  private

  def invited_user_not_already_active_member
    return unless team && invited_user
    if team.members.include?(invited_user)
      errors.add(:invited_user, :already_member)
    end
  end
end
