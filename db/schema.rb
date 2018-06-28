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

ActiveRecord::Schema.define(version: 2018_06_28_093136) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "announcements", force: :cascade do |t|
    t.datetime "published_at"
    t.string "announcement_type"
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "availabilities", force: :cascade do |t|
    t.date "available_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "check_out_only", default: false
    t.bigint "lodging_child_id"
    t.index ["lodging_child_id"], name: "index_availabilities_on_lodging_child_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.text "content"
    t.boolean "disable", default: true
    t.string "slug"
    t.string "title"
    t.string "meta_title"
    t.text "villas_desc"
    t.text "apartment_desc"
    t.text "bb_desc"
    t.boolean "dropdown", default: false
    t.boolean "sidebar", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "discounts", force: :cascade do |t|
    t.bigint "lodging_id"
    t.date "start_date"
    t.date "end_date"
    t.integer "reservation_days"
    t.float "discount_percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lodging_id"], name: "index_discounts_on_lodging_id"
  end

  create_table "lodging_children", force: :cascade do |t|
    t.bigint "lodging_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.index ["lodging_id"], name: "index_lodging_children_on_lodging_id"
  end

  create_table "lodging_translations", force: :cascade do |t|
    t.integer "lodging_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "subtitle"
    t.text "description"
    t.index ["locale"], name: "index_lodging_translations_on_locale"
    t.index ["lodging_id"], name: "index_lodging_translations_on_lodging_id"
  end

  create_table "lodgings", force: :cascade do |t|
    t.string "street"
    t.string "city"
    t.string "zip"
    t.string "state"
    t.integer "beds"
    t.integer "baths"
    t.float "sq__ft"
    t.datetime "sale_date"
    t.integer "price"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lodging_type", default: 1
    t.integer "adults", default: 1
    t.integer "children", default: 1
    t.integer "infants", default: 1
    t.string "title"
    t.string "subtitle"
    t.text "description"
    t.bigint "owner_id"
    t.json "images"
    t.bigint "region_id"
    t.string "slug"
    t.string "name"
    t.string "meta_title"
    t.string "h1"
    t.string "h2"
    t.string "h3"
    t.string "highlight_1"
    t.string "highlight_2"
    t.string "highlight_3"
    t.string "label"
    t.text "summary"
    t.text "location_description"
    t.text "meta_desc"
    t.text "short_desc"
    t.boolean "published", default: false
    t.boolean "heads", default: false
    t.boolean "confirmed_price", default: false
    t.boolean "include_cleaning", default: false
    t.boolean "include_deposit", default: false
    t.boolean "checked", default: false
    t.boolean "flexible", default: false
    t.boolean "listed_to", default: false
    t.boolean "ical_validated", default: false
    t.datetime "route_updated_at"
    t.datetime "price_updated_at"
    t.integer "status"
    t.index ["owner_id"], name: "index_lodgings_on_owner_id"
    t.index ["region_id"], name: "index_lodgings_on_region_id"
  end

  create_table "owners", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
    t.index ["email"], name: "index_owners_on_email", unique: true
    t.index ["reset_password_token"], name: "index_owners_on_reset_password_token", unique: true
  end

  create_table "prices", force: :cascade do |t|
    t.float "amount", default: 0.0
    t.integer "adults", default: 1
    t.integer "children", default: 1
    t.integer "infants", default: 1
    t.bigint "availability_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["availability_id"], name: "index_prices_on_availability_id"
  end

  create_table "regions", force: :cascade do |t|
    t.string "name"
    t.bigint "country_id"
    t.text "content"
    t.string "slug"
    t.string "title"
    t.string "meta_title"
    t.text "villas_desc"
    t.text "apartment_desc"
    t.text "bb_desc"
    t.text "short_desc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_regions_on_country_id"
  end

  create_table "reservations", force: :cascade do |t|
    t.bigint "user_id"
    t.date "check_in"
    t.date "check_out"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "adults", default: 0
    t.integer "children", default: 0
    t.integer "infants", default: 0
    t.float "total_price", default: 0.0
    t.float "rent", default: 0.0
    t.float "discount", default: 0.0
    t.float "cleaning_cost", default: 0.0
    t.integer "booking_status", default: 0
    t.integer "request_status", default: 0
    t.bigint "lodging_child_id"
    t.index ["lodging_child_id"], name: "index_reservations_on_lodging_child_id"
    t.index ["user_id"], name: "index_reservations_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "lodging_id"
    t.bigint "user_id"
    t.integer "stars"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "setting", default: 0.0
    t.float "quality", default: 0.0
    t.float "interior", default: 0.0
    t.float "communication", default: 0.0
    t.float "service", default: 0.0
    t.text "suggetion"
    t.string "title"
    t.bigint "reservation_id"
    t.index ["lodging_id"], name: "index_reviews_on_lodging_id"
    t.index ["reservation_id"], name: "index_reviews_on_reservation_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "rules", force: :cascade do |t|
    t.bigint "lodging_id"
    t.date "start_date"
    t.date "end_date"
    t.integer "days_multiplier"
    t.string "check_in_days"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lodging_id"], name: "index_rules_on_lodging_id"
  end

  create_table "specifications", force: :cascade do |t|
    t.bigint "lodging_id"
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lodging_id"], name: "index_specifications_on_lodging_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "first_name"
    t.string "last_name"
    t.datetime "announcements_last_read_at"
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "availabilities", "lodging_children"
  add_foreign_key "discounts", "lodgings", on_delete: :cascade
  add_foreign_key "lodging_children", "lodgings", on_delete: :cascade
  add_foreign_key "lodgings", "owners", on_delete: :cascade
  add_foreign_key "lodgings", "regions", on_delete: :cascade
  add_foreign_key "prices", "availabilities", on_delete: :cascade
  add_foreign_key "regions", "countries", on_delete: :cascade
  add_foreign_key "reservations", "lodging_children"
  add_foreign_key "reservations", "users"
  add_foreign_key "reviews", "lodgings"
  add_foreign_key "reviews", "reservations", on_delete: :cascade
  add_foreign_key "reviews", "users"
  add_foreign_key "rules", "lodgings", on_delete: :cascade
  add_foreign_key "specifications", "lodgings"
end
