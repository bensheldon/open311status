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

ActiveRecord::Schema.define(version: 2018_08_20_013552) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "cities", force: :cascade do |t|
    t.string "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "service_definitions_count", default: 0, null: false
    t.index ["slug"], name: "index_cities_on_slug", unique: true
  end

  create_table "que_jobs", primary_key: ["queue", "priority", "run_at", "job_id"], comment: "3", force: :cascade do |t|
    t.integer "priority", limit: 2, default: 100, null: false
    t.datetime "run_at", default: -> { "now()" }, null: false
    t.bigserial "job_id", null: false
    t.text "job_class", null: false
    t.json "args", default: [], null: false
    t.integer "error_count", default: 0, null: false
    t.text "last_error"
    t.text "queue", default: "", null: false
  end

  create_table "service_definitions", force: :cascade do |t|
    t.integer "city_id"
    t.string "service_code"
    t.json "raw_data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["city_id", "service_code"], name: "index_service_definitions_on_city_id_and_service_code"
    t.index ["city_id"], name: "index_service_definitions_on_city_id"
  end

  create_table "service_requests", force: :cascade do |t|
    t.string "service_request_id"
    t.string "status"
    t.datetime "requested_datetime"
    t.datetime "updated_datetime"
    t.json "raw_data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "city_id"
    t.geography "geometry", limit: {:srid=>4326, :type=>"geometry", :geographic=>true}
    t.index ["city_id", "service_request_id"], name: "index_service_requests_on_city_id_and_service_request_id", unique: true
    t.index ["city_id"], name: "index_service_requests_on_city_id"
    t.index ["geometry"], name: "index_service_requests_on_geometry", using: :gist
    t.index ["status"], name: "index_service_requests_on_status"
  end

  create_table "statuses", force: :cascade do |t|
    t.integer "city_id"
    t.string "request_name"
    t.integer "duration_ms"
    t.integer "http_code"
    t.datetime "created_at"
    t.text "error_message"
    t.index ["city_id", "request_name"], name: "index_statuses_on_city_id_and_request_name"
    t.index ["city_id"], name: "index_statuses_on_city_id"
  end

end
