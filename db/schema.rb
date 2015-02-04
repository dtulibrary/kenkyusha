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

ActiveRecord::Schema.define(version: 20150204110745) do

  create_table "bookmarks", force: true do |t|
    t.integer  "user_id",       null: false
    t.string   "user_type"
    t.string   "document_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "document_type"
  end

  add_index "bookmarks", ["user_id"], name: "index_bookmarks_on_user_id"

  create_table "orcid_stats", force: true do |t|
    t.integer  "aau",        default: 0
    t.integer  "au",         default: 0
    t.integer  "cbs",        default: 0
    t.integer  "dtu",        default: 0
    t.integer  "itu",        default: 0
    t.integer  "ku",         default: 0
    t.integer  "ruc",        default: 0
    t.integer  "sdu",        default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ark",        default: 0
    t.integer  "fak",        default: 0
    t.integer  "ka",         default: 0
    t.integer  "sbi",        default: 0
    t.integer  "ucviden",    default: 0
  end

  create_table "searches", force: true do |t|
    t.text     "query_params"
    t.integer  "user_id"
    t.string   "user_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "searches", ["user_id"], name: "index_searches_on_user_id"

end
