class BackfillPublicIdsForGamesAndTeams < ActiveRecord::Migration[8.1]
  SEGMENT_LENGTH = 8
  SEGMENT_CHARSET = [ *"A".."Z", *"a".."z", *"0".."9" ].freeze

  def up
    backfill_table(:games, "gm")
    backfill_table(:teams, "tm")
  end

  def down
    # No-op: removing the column is handled by the add_column migration rollback
  end

  private

  def backfill_table(table, prefix)
    used_segments = Set.new

    # Collect existing segments from both tables
    execute("SELECT public_id FROM games WHERE public_id IS NOT NULL").each do |row|
      seg = row["public_id"]&.split("_", 2)&.last
      used_segments.add(seg) if seg
    end
    execute("SELECT public_id FROM teams WHERE public_id IS NOT NULL").each do |row|
      seg = row["public_id"]&.split("_", 2)&.last
      used_segments.add(seg) if seg
    end

    execute("SELECT id FROM #{table} WHERE public_id IS NULL").each do |row|
      id = row["id"]
      segment = nil
      5.times do
        candidate = Array.new(SEGMENT_LENGTH) { SEGMENT_CHARSET.sample }.join
        unless used_segments.include?(candidate)
          segment = candidate
          break
        end
      end

      raise "Could not generate unique segment for #{table} ##{id}" unless segment

      used_segments.add(segment)
      public_id = "#{prefix}_#{segment}"
      execute("UPDATE #{table} SET public_id = #{quote(public_id)} WHERE id = #{quote(id)}")
    end
  end
end
