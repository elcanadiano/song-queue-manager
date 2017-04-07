# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170407030646) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "artists", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "artists", ["name"], name: "index_artists_on_name", using: :btree

  create_table "artists_songs", id: false, force: :cascade do |t|
    t.integer "song_id"
    t.integer "artist_id"
  end

  add_index "artists_songs", ["artist_id"], name: "index_artists_songs_on_artist_id", using: :btree
  add_index "artists_songs", ["song_id"], name: "index_artists_songs_on_song_id", using: :btree

  create_table "bands", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "bands", ["name"], name: "index_bands_on_name", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "name",                          null: false
    t.date     "date",                          null: false
    t.boolean  "is_open",       default: false, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "soundtrack_id"
    t.integer  "song_order",    default: 0,     null: false
  end

  add_index "events", ["is_open", "date"], name: "index_events_on_is_open_and_date", using: :btree

  create_table "members", force: :cascade do |t|
    t.boolean  "is_admin",   default: false, null: false
    t.integer  "user_id"
    t.integer  "band_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "members", ["band_id"], name: "index_members_on_band_id", using: :btree
  add_index "members", ["user_id"], name: "index_members_on_user_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.string   "notification_type"
    t.integer  "user_id"
    t.integer  "creator_id"
    t.integer  "band_id"
    t.boolean  "has_expired",       default: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "notifications", ["band_id"], name: "index_notifications_on_band_id", using: :btree
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "song_requests", force: :cascade do |t|
    t.integer  "song_order", default: 0, null: false
    t.integer  "event_id"
    t.integer  "band_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "song_id"
    t.integer  "status",     default: 0, null: false
  end

  add_index "song_requests", ["band_id"], name: "index_song_requests_on_band_id", using: :btree
  add_index "song_requests", ["event_id"], name: "index_song_requests_on_event_id", using: :btree
  add_index "song_requests", ["song_order"], name: "index_song_requests_on_song_order", using: :btree

  create_table "songs", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "song_by_artist"
  end

  add_index "songs", ["name"], name: "index_songs_on_name", using: :btree

  create_table "songs_soundtracks", id: false, force: :cascade do |t|
    t.integer "song_id"
    t.integer "soundtrack_id"
  end

  add_index "songs_soundtracks", ["song_id"], name: "index_songs_soundtracks_on_song_id", using: :btree
  add_index "songs_soundtracks", ["soundtrack_id"], name: "index_songs_soundtracks_on_soundtrack_id", using: :btree

  create_table "soundtracks", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "description"
  end

  add_index "soundtracks", ["name"], name: "index_soundtracks_on_name", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "password_digest"
    t.string   "remember_digest"
    t.boolean  "admin"
    t.string   "activation_digest"
    t.boolean  "activated"
    t.datetime "activated_at"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
  end

  add_foreign_key "members", "bands"
  add_foreign_key "members", "users"
  add_foreign_key "notifications", "bands"
  add_foreign_key "song_requests", "bands"
  add_foreign_key "song_requests", "events"
end
