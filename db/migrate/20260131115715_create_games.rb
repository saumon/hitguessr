class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.references :team, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end
    add_index :games, :status
  end
end
