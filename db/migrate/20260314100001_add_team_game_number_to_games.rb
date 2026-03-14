class AddTeamGameNumberToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :team_game_number, :integer
  end
end
