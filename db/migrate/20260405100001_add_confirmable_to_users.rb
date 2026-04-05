class AddConfirmableToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :confirmation_token,   :string
    add_column :users, :confirmed_at,         :datetime
    add_column :users, :confirmation_sent_at, :datetime
    # unconfirmed_email is used by Devise reconfirmable flow (config.reconfirmable = true)
    add_column :users, :unconfirmed_email,    :string

    # Unique index on confirmation_token for fast, safe token lookups (T056)
    add_index :users, :confirmation_token, unique: true

    # Email uniqueness at DB level is already enforced by the existing unique index on email.
    # Case-insensitive auth is handled by Devise case_insensitive_keys (see config/initializers/devise.rb).
  end

  def down
    remove_index  :users, :confirmation_token
    remove_column :users, :unconfirmed_email
    remove_column :users, :confirmation_sent_at
    remove_column :users, :confirmed_at
    remove_column :users, :confirmation_token
  end
end
