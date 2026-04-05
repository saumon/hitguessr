# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_05_100002) do
  create_table "games", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.string "public_id", null: false
    t.datetime "started_at"
    t.integer "status", default: 0, null: false
    t.integer "team_game_number", null: false
    t.integer "team_id", null: false
    t.datetime "updated_at", null: false
    t.index ["public_id"], name: "index_games_on_public_id", unique: true
    t.index ["status"], name: "index_games_on_status"
    t.index ["team_id", "team_game_number"], name: "index_games_on_team_id_and_team_game_number", unique: true
    t.index ["team_id"], name: "index_games_on_team_id"
  end

  create_table "guesses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "guessed_author_id", null: false
    t.integer "player_id", null: false
    t.integer "proposal_id", null: false
    t.datetime "updated_at", null: false
    t.index ["guessed_author_id"], name: "index_guesses_on_guessed_author_id"
    t.index ["player_id", "proposal_id"], name: "index_guesses_on_player_id_and_proposal_id", unique: true
    t.index ["player_id"], name: "index_guesses_on_player_id"
    t.index ["proposal_id"], name: "index_guesses_on_proposal_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "team_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["team_id"], name: "index_memberships_on_team_id"
    t.index ["user_id", "team_id"], name: "index_memberships_on_user_id_and_team_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "proposals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "game_id", null: false
    t.integer "guess_order_position"
    t.integer "player_id", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["game_id", "guess_order_position"], name: "index_proposals_on_game_id_and_guess_order_position"
    t.index ["game_id", "player_id"], name: "index_proposals_on_game_id_and_player_id", unique: true
    t.index ["game_id", "url"], name: "index_proposals_on_game_id_and_url", unique: true
    t.index ["game_id"], name: "index_proposals_on_game_id"
    t.index ["player_id"], name: "index_proposals_on_player_id"
  end

  create_table "team_invitations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "invited_by_id", null: false
    t.integer "invited_user_id", null: false
    t.datetime "responded_at"
    t.integer "status", default: 0, null: false
    t.integer "team_id", null: false
    t.datetime "updated_at", null: false
    t.index ["invited_by_id"], name: "index_team_invitations_on_invited_by_id"
    t.index ["invited_user_id"], name: "index_team_invitations_on_invited_user_id"
    t.index ["status"], name: "idx_team_invitations_status"
    t.index ["team_id", "invited_user_id"], name: "idx_team_invitations_team_user"
    t.index ["team_id", "invited_user_id"], name: "idx_unique_team_invitations_pending", unique: true, where: "status = 0"
    t.index ["team_id"], name: "index_team_invitations_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "organizer_id", null: false
    t.string "public_id", null: false
    t.datetime "updated_at", null: false
    t.index ["organizer_id"], name: "index_teams_on_organizer_id"
    t.index ["public_id"], name: "index_teams_on_public_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "games", "teams"
  add_foreign_key "guesses", "proposals"
  add_foreign_key "guesses", "users", column: "guessed_author_id"
  add_foreign_key "guesses", "users", column: "player_id"
  add_foreign_key "memberships", "teams"
  add_foreign_key "memberships", "users"
  add_foreign_key "proposals", "games"
  add_foreign_key "proposals", "users", column: "player_id"
  add_foreign_key "team_invitations", "teams"
  add_foreign_key "team_invitations", "users", column: "invited_by_id"
  add_foreign_key "team_invitations", "users", column: "invited_user_id"
  add_foreign_key "teams", "users", column: "organizer_id"
end
