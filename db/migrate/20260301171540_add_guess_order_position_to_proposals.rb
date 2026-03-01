class AddGuessOrderPositionToProposals < ActiveRecord::Migration[8.1]
  def change
    add_column :proposals, :guess_order_position, :integer
    add_index :proposals, [ :game_id, :guess_order_position ],
              name: "index_proposals_on_game_id_and_guess_order_position"
  end
end
