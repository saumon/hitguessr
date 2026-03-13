class EnforcePublicIdConstraints < ActiveRecord::Migration[8.1]
  def change
    change_column_null :games, :public_id, false
    change_column_null :teams, :public_id, false
    add_index :games, :public_id, unique: true
    add_index :teams, :public_id, unique: true
  end
end
