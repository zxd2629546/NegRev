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

ActiveRecord::Schema.define(version: 20160116130144) do

  create_table "bad_comments", force: :cascade do |t|
    t.string   "name"
    t.date     "release_time"
    t.text     "content"
    t.integer  "product_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "user_id"
  end

  add_index "bad_comments", ["product_id"], name: "index_bad_comments_on_product_id"
  add_index "bad_comments", ["user_id"], name: "index_bad_comments_on_user_id"

  create_table "comments", force: :cascade do |t|
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "product_id"
  end

  add_index "comments", ["product_id"], name: "index_comments_on_product_id"

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.text     "desc"
    t.string   "img"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "tags"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin"
  end

  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

end
