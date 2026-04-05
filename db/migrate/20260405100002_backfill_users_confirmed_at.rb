class BackfillUsersConfirmedAt < ActiveRecord::Migration[8.1]
  # Mark all pre-existing users as confirmed so they are not locked out
  # when the Devise confirmable module is enabled.
  # Uses raw SQL to avoid dependency on model callbacks or current schema state.
  def up
    execute "UPDATE users SET confirmed_at = created_at WHERE confirmed_at IS NULL"
  end

  def down
    # Irreversible: cannot distinguish backfilled from genuinely confirmed rows.
    # Noop on rollback; re-enabling would re-lock pre-existing accounts.
  end
end
