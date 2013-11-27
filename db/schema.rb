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

ActiveRecord::Schema.define(version: 20131125114957) do

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"

  create_table "admin_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true

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

  create_table "user_email_files", force: true do |t|
    t.integer  "user_email_id"
    t.string   "filename"
    t.integer  "size"
    t.string   "link"
    t.datetime "created_at"
    t.string   "ext"
  end

  create_table "user_emails", force: true do |t|
    t.integer "user_id"
    t.string  "label"
    t.string  "subject"
    t.string  "from"
    t.string  "to"
    t.integer "date"
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
    t.string   "email",             default: "", null: false
    t.string   "picture"
    t.string   "uid"
    t.string   "persistence_token",              null: false
    t.integer  "login_count",       default: 0,  null: false
    t.datetime "current_login_at"
    t.string   "current_login_ip"
    t.datetime "last_login_at"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_sync"
  end

end
