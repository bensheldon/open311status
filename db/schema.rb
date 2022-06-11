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

ActiveRecord::Schema.define(version: 2022_06_11_013909) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "cities", force: :cascade do |t|
    t.string "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "service_definitions_count", default: 0, null: false
    t.index ["slug"], name: "index_cities_on_slug", unique: true
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "state"
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["active_job_id"], name: "index_good_jobs_on_active_job_id"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at", unique: true
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
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
    t.index ["city_id", "requested_datetime"], name: "index_service_requests_on_city_id_and_requested_datetime", order: { requested_datetime: "DESC NULLS LAST" }
    t.index ["city_id", "service_request_id"], name: "index_service_requests_on_city_id_and_service_request_id", unique: true
    t.index ["city_id"], name: "index_service_requests_on_city_id"
    t.index ["geometry"], name: "index_service_requests_on_geometry", using: :gist
    t.index ["requested_datetime"], name: "index_service_requests_on_requested_datetime", order: "DESC NULLS LAST"
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
  end


  create_view "global_indices", materialized: true, sql_definition: <<-SQL
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
