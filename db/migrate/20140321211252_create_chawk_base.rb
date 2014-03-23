## ~~~- Created via -~~~

class CreateChawkBase < ActiveRecord::Migration
	def up
		create_table "chawk_agents", force: true do |t|
			t.integer "foreign_id"
			t.string  "name",       limit: 200
			t.timestamps
		end

		create_table "chawk_nodes", force: true do |t|
			t.string  "key",     		limit: 150
			t.text  "decription"
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

		add_index "chawk_points", ["node_id"], name: "index_chawk_points_node", using: :btree

		create_table "chawk_values", force: true do |t|
			t.float    "observed_at"
			t.datetime "recorded_at"
			t.text     "meta"
			t.text     "value"
			t.integer  "node_id",     null: false
		end

		add_index "chawk_values", ["node_id"], name: "index_chawk_values_node", using: :btree

		create_table "chawk_relations", force: true do |t|
			t.boolean "admin",    default: false
			t.boolean "read",     default: false
			t.boolean "write",    default: false
			t.integer "agent_id",                 null: false
			t.integer "node_id",                  null: false
		end

		add_index "chawk_relations", ["agent_id"], name: "index_chawk_relations_agent", using: :btree
		add_index "chawk_relations", ["node_id"], name: "index_chawk_relations_node", using: :btree
	end

	def down
		drop_table "chawk_agents"
		drop_table "chawk_nodes"
		drop_table "chawk_points"
		drop_table "chawk_values"
		drop_table "chawk_relations"
	end

end

