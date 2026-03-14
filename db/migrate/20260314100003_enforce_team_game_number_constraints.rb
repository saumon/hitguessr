class EnforceTeamGameNumberConstraints < ActiveRecord::Migration[8.1]
  def change
    change_column_null :games, :team_game_number, false
    add_index :games, [ :team_id, :team_game_number ], unique: true,
              name: "index_games_on_team_id_and_team_game_number"
  end
end
