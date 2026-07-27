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

ActiveRecord::Schema[8.1].define(version: 2026_07_27_140505) do
  create_table "api_users", charset: "utf8mb4", force: :cascade do |t|
    t.string "api_key", null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.bigint "unit_id"
    t.datetime "updated_at", null: false
    t.text "webhook_endpoint"
    t.string "webhook_key"
    t.index ["api_key"], name: "index_api_users_on_api_key", unique: true
    t.index ["unit_id"], name: "index_api_users_on_unit_id"
    t.index ["webhook_key"], name: "index_api_users_on_webhook_key", unique: true
  end

  create_table "gui_users", charset: "utf8mb4", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.bigint "unit_id"
    t.datetime "updated_at", null: false
    t.index ["unit_id"], name: "index_gui_users_on_unit_id"
  end

  create_table "jobs", charset: "utf8mb4", force: :cascade do |t|
    t.text "alt_text"
    t.datetime "created_at", null: false
    t.string "filename"
    t.datetime "finished_at"
    t.string "llm_model"
    t.text "object_key"
    t.text "output_url"
    t.datetime "output_url_expires_at"
    t.bigint "owner_id", null: false
    t.string "owner_type", null: false
    t.integer "page_count"
    t.text "processing_error_message"
    t.text "prompt"
    t.text "source_url"
    t.string "status", null: false
    t.string "type"
    t.datetime "updated_at", null: false
    t.string "uuid", null: false
    t.index ["owner_type", "owner_id"], name: "index_jobs_on_owner"
    t.index ["uuid"], name: "index_jobs_on_uuid"
  end

  create_table "units", charset: "utf8mb4", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "overall_page_limit", default: 25000, null: false
    t.datetime "updated_at", null: false
    t.integer "user_daily_page_limit", default: 30, null: false
  end

  add_foreign_key "api_users", "units"
  add_foreign_key "gui_users", "units"
end
