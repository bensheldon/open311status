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

ActiveRecord::Schema.define(version: 20141208020641) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cities", force: true do |t|
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cities", ["slug"], name: "index_cities_on_slug", unique: true, using: :btree

  create_table "service_requests", force: true do |t|
    t.string   "service_request_id"
    t.string   "status"
    t.datetime "requested_datetime"
    t.datetime "updated_datetime"
    t.json     "raw_data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "city_id"
  end

  add_index "service_requests", ["city_id", "service_request_id"], name: "index_service_requests_on_city_id_and_service_request_id", unique: true, using: :btree
  add_index "service_requests", ["city_id"], name: "index_service_requests_on_city_id", using: :btree
  add_index "service_requests", ["status"], name: "index_service_requests_on_status", using: :btree

  create_table "statuses", force: true do |t|
    t.integer  "city_id"
    t.string   "request_name"
    t.integer  "duration_ms"
    t.integer  "http_code"
    t.datetime "created_at"
  end

  add_index "statuses", ["city_id", "request_name"], name: "index_statuses_on_city_id_and_request_name", using: :btree
  add_index "statuses", ["city_id"], name: "index_statuses_on_city_id", using: :btree

end
