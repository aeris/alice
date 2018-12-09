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

ActiveRecord::Schema.define(version: 2018_11_27_204747) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "diffs", force: :cascade do |t|
    t.json "content", null: false
    t.bigint "site_id", null: false
    t.datetime "created_at", null: false
    t.index ["site_id"], name: "index_diffs_on_site_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "template_id"
    t.index ["name"], name: "index_groups_on_name", unique: true
    t.index ["template_id"], name: "index_groups_on_template_id"
  end

  create_table "sites", force: :cascade do |t|
    t.string "url", null: false
    t.string "name"
    t.text "reference"
    t.bigint "group_id"
    t.bigint "template_id"
    t.string "last_error"
    t.datetime "checked_at"
    t.datetime "changed_at"
    t.index ["group_id"], name: "index_sites_on_group_id"
    t.index ["name"], name: "index_sites_on_name"
    t.index ["template_id"], name: "index_sites_on_template_id"
  end

  create_table "targets", force: :cascade do |t|
    t.string "name"
    t.string "css"
    t.string "from"
    t.string "to"
    t.bigint "template_id"
    t.bigint "group_id"
    t.bigint "site_id"
    t.index ["group_id"], name: "index_targets_on_group_id"
    t.index ["site_id"], name: "index_targets_on_site_id"
    t.index ["template_id"], name: "index_targets_on_template_id"
  end

  create_table "templates", force: :cascade do |t|
    t.string "name"
    t.index ["name"], name: "index_templates_on_name", unique: true
  end

  add_foreign_key "diffs", "sites"
  add_foreign_key "groups", "templates"
  add_foreign_key "sites", "groups"
  add_foreign_key "sites", "templates"
  add_foreign_key "targets", "groups"
  add_foreign_key "targets", "sites"
  add_foreign_key "targets", "templates"
end
