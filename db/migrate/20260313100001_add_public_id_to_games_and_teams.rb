class AddPublicIdToGamesAndTeams < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :public_id, :string
    add_column :teams, :public_id, :string
  end
end
