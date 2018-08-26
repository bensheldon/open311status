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

ActiveRecord::Schema.define(version: 2018_08_26_150559) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
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
    t.index ["city_id", "request_name", "created_at"], name: "index_statuses_on_city_id_and_request_name_and_created_at", order: { created_at: :desc }
    t.index ["city_id", "request_name"], name: "index_statuses_on_city_id_and_request_name"
    t.index ["city_id"], name: "index_statuses_on_city_id"
  end


  create_view "global_indices", materialized: true,  sql_definition: <<-SQL
      WITH service_request_indices AS (
           SELECT ('ServiceRequest-'::text || service_requests.id) AS id,
              'ServiceRequest'::text AS searchable_type,
              (service_requests.id)::integer AS searchable_id,
              ((((COALESCE((service_requests.raw_data ->> 'description'::text), ''::text) || ' '::text) || COALESCE((service_requests.raw_data ->> 'service_name'::text), ''::text)) || ' '::text) || COALESCE((cities.slug)::text, ''::text)) AS content
             FROM (service_requests
               LEFT JOIN cities ON ((cities.id = service_requests.city_id)))
          )
   SELECT service_request_indices.id,
      service_request_indices.searchable_type,
      service_request_indices.searchable_id,
      service_request_indices.content
     FROM service_request_indices;
  SQL

  add_index "global_indices", "to_tsvector('english'::regconfig, content)", name: "index_global_indices_on_to_tsvector_english_content", using: :gin
  add_index "global_indices", ["content"], name: "index_global_indices_on_content_gist_trgm_ops", opclass: :gist_trgm_ops, using: :gist
  add_index "global_indices", ["id"], name: "index_global_indices_on_id", unique: true

end
