class BackfillTeamGameNumbers < ActiveRecord::Migration[8.1]
  def up
    # Pour chaque équipe, on assigne des numéros séquentiels en ordre chronologique
    execute(<<~SQL)
      WITH ranked AS (
        SELECT id, ROW_NUMBER() OVER (
          PARTITION BY team_id
          ORDER BY created_at ASC, id ASC
        ) AS rn
        FROM games
        WHERE team_id IS NOT NULL
      )
      UPDATE games
      SET team_game_number = ranked.rn
      FROM ranked
      WHERE games.id = ranked.id
    SQL
  end

  def down
    update_all "team_game_number = NULL"
  end

  private

  def update_all(sql)
    execute("UPDATE games SET #{sql}")
  end
end
