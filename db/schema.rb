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

ActiveRecord::Schema.define(version: 20140322230012) do

  create_table "api_keys", force: true do |t|
    t.string   "access_token"
    t.integer  "user_id"
    t.datetime "expires"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "chawk_agents", force: true do |t|
    t.integer  "foreign_id"
    t.string   "name",       limit: 200
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "chawk_nodes", force: true do |t|
    t.string  "key",          limit: 150
    t.text    "decription"
    t.boolean "public_read",              default: false
    t.boolean "public_write",             default: false
  end

  create_table "chawk_points", force: true do |t|
    t.float    "observed_at"
    t.datetime "recorded_at"
    t.text     "meta"
    t.integer  "value"
    t.integer  "node_id",     null: false
  end

  add_index "chawk_points", ["node_id"], name: "index_chawk_points_node"

  create_table "chawk_relations", force: true do |t|
    t.boolean "admin",    default: false
    t.boolean "read",     default: false
    t.boolean "write",    default: false
    t.integer "agent_id",                 null: false
    t.integer "node_id",                  null: false
  end

  add_index "chawk_relations", ["agent_id"], name: "index_chawk_relations_agent"
  add_index "chawk_relations", ["node_id"], name: "index_chawk_relations_node"

  create_table "chawk_values", force: true do |t|
    t.float    "observed_at"
    t.datetime "recorded_at"
    t.text     "meta"
    t.text     "value"
    t.integer  "node_id",     null: false
  end

  add_index "chawk_values", ["node_id"], name: "index_chawk_values_node"

  create_table "users", force: true do |t|
    t.string   "uid"
    t.string   "api_client_id"
    t.string   "provider"
    t.string   "provider_email"
    t.string   "email"
    t.string   "handle"
    t.string   "name"
    t.string   "image_url"
    t.integer  "agent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",     default: 0, null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

end
