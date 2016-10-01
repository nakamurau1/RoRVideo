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

ActiveRecord::Schema.define(version: 20150418052940) do

  create_table "followed_lists", force: true do |t|
    t.integer  "user_id"
    t.integer  "list_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "list_items", force: true do |t|
    t.integer  "list_id"
    t.integer  "video_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "list_items", ["list_id"], name: "index_list_items_on_list_id"

  create_table "lists", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "followers_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "comment"
    t.boolean  "private"
  end

  add_index "lists", ["user_id"], name: "index_lists_on_user_id"

  create_table "microposts", force: true do |t|
    t.string   "content"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "microposts", ["user_id", "created_at"], name: "index_microposts_on_user_id_and_created_at"

  create_table "relationships", force: true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["followed_id"], name: "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true
  add_index "relationships", ["follower_id"], name: "index_relationships_on_follower_id"

  create_table "users", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",           default: false
    t.string   "uniq_user_name"
  end

  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

  create_table "video_comments", force: true do |t|
    t.integer  "video_id"
    t.integer  "user_id"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "video_comments", ["video_id", "created_at"], name: "index_video_comments_on_video_id_and_created_at"

  create_table "videos", force: true do |t|
    t.integer  "view_count",    default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "thumbnail_url"
    t.string   "title"
    t.string   "v_id"
    t.string   "video_type"
    t.string   "play_time"
  end

  add_index "videos", ["created_at"], name: "index_videos_on_created_at"
  add_index "videos", ["play_time"], name: "index_videos_on_play_time"

end
