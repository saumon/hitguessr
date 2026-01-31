class CreateProposals < ActiveRecord::Migration[8.1]
  def change
    create_table :proposals do |t|
      t.references :game, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: { to_table: :users }
      t.string :url, null: false

      t.timestamps
    end
    add_index :proposals, [ :game_id, :url ], unique: true
    add_index :proposals, [ :game_id, :player_id ], unique: true
  end
end
