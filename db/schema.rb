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

ActiveRecord::Schema.define(version: 20140227210624) do

  create_table "email_files", force: true do |t|
    t.integer  "email_id"
    t.string   "filename"
    t.integer  "size"
    t.string   "link"
    t.datetime "created_at"
    t.string   "ext"
    t.integer  "status"
  end

  create_table "emails", force: true do |t|
    t.integer "user_id"
    t.string  "label"
    t.string  "subject"
    t.string  "from"
    t.string  "to"
    t.integer "date"
  end

  create_table "extensions", force: true do |t|
    t.string "extension"
    t.string "file_type"
    t.string "folder"
    t.string "sub_folder"
  end

  create_table "filters", force: true do |t|
    t.integer "user_id"
    t.boolean "images_filters"
    t.string  "images_extensions"
    t.integer "images_min_size"
    t.integer "images_max_size"
    t.boolean "documents_filters"
    t.string  "documents_extensions"
    t.integer "documents_min_size"
    t.integer "documents_max_size"
  end

  create_table "user_profiles", force: true do |t|
    t.integer  "user_id"
    t.string   "plus"
    t.string   "twitter"
    t.string   "facebook"
    t.string   "gender"
    t.string   "organization"
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_settings", force: true do |t|
    t.integer "user_id"
    t.boolean "convert_files"
    t.boolean "subject_in_filename", default: false
    t.boolean "active",              default: true
    t.boolean "logging",             default: false
  end

  create_table "user_synchronizations", force: true do |t|
    t.integer "user_id"
    t.integer "status"
    t.integer "email_count",     default: 0
    t.integer "email_parsed",    default: 0
    t.integer "previous_status"
    t.integer "started_at"
  end

  create_table "user_tokens", force: true do |t|
    t.string  "user_id"
    t.string  "access_token"
    t.string  "refresh_token"
    t.integer "issued_at"
    t.integer "expires_in"
  end

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email",             default: "",    null: false
    t.string   "picture"
    t.string   "uid"
    t.string   "persistence_token",                 null: false
    t.integer  "login_count",       default: 0,     null: false
    t.datetime "current_login_at"
    t.string   "current_login_ip"
    t.datetime "last_login_at"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_sync"
    t.integer  "first_sync_at"
    t.boolean  "is_admin",          default: false
  end

end
