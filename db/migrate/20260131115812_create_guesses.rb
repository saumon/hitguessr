class CreateGuesses < ActiveRecord::Migration[8.1]
  def change
    create_table :guesses do |t|
      t.references :player, null: false, foreign_key: { to_table: :users }
      t.references :proposal, null: false, foreign_key: true
      t.references :guessed_author, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :guesses, [ :player_id, :proposal_id ], unique: true
  end
end
