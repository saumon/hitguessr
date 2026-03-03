class CreateTeamInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :team_invitations do |t|
      t.references :team,          null: false, foreign_key: true
      t.references :invited_user,  null: false, foreign_key: { to_table: :users }
      t.references :invited_by,    null: false, foreign_key: { to_table: :users }
      t.integer    :status,        null: false, default: 0  # 0=pending, 1=accepted, 2=refused
      t.datetime   :responded_at

      t.timestamps
    end

    # Index de recherche rapide
    add_index :team_invitations, [ :team_id, :invited_user_id ],
              name: :idx_team_invitations_team_user
    add_index :team_invitations, :status,
              name: :idx_team_invitations_status

    # Index unicité partiel : pas de doublon d'invitation pending pour un même couple
    add_index :team_invitations,
              [ :team_id, :invited_user_id ],
              unique: true,
              where: "status = 0",
              name: :idx_unique_team_invitations_pending
  end
end
