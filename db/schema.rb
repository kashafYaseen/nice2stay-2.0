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

ActiveRecord::Schema.define(version: 2019_07_11_064134) do

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

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
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
    t.string "image"
    t.string "first_name"
    t.string "last_name"
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "ahoy_events", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties_jsonb_path_ops", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.bigint "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.string "app_version"
    t.string "os_version"
    t.string "platform"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
  end

  create_table "amenities", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.boolean "filter_enabled"
    t.boolean "hot"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "amenity_translations", force: :cascade do |t|
    t.integer "amenity_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "slug"
    t.index ["amenity_id"], name: "index_amenity_translations_on_amenity_id"
    t.index ["locale"], name: "index_amenity_translations_on_locale"
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
    t.bigint "lodging_id"
    t.index ["lodging_id"], name: "index_availabilities_on_lodging_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "user_id"
    t.boolean "confirmed", default: false
    t.boolean "in_cart", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uid"
    t.string "be_identifier"
    t.float "pre_payment", default: 0.0
    t.float "final_payment", default: 0.0
    t.boolean "refund_payment", default: false
    t.string "pre_payment_mollie_id"
    t.string "final_payment_mollie_id"
    t.datetime "pre_payed_at"
    t.datetime "final_payed_at"
    t.integer "booking_status", default: 0
    t.integer "crm_id"
    t.integer "created_by", default: 0
    t.boolean "canceled", default: false
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "campaign_translations", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "description"
    t.string "url"
    t.string "crm_urls"
    t.index ["campaign_id"], name: "index_campaign_translations_on_campaign_id"
    t.index ["locale"], name: "index_campaign_translations_on_locale"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.string "crm_urls"
    t.string "url"
    t.string "article_spotlight"
    t.text "publish", default: [], array: true
    t.text "images", default: [], array: true
    t.text "description"
    t.text "slider_desc"
    t.integer "price"
    t.boolean "slider"
    t.boolean "spotlight"
    t.boolean "popular_search"
    t.boolean "popular_homepage"
    t.boolean "collection"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "thumbnails", default: [], array: true
  end

  create_table "campaigns_regions", force: :cascade do |t|
    t.bigint "campaign_id"
    t.bigint "region_id"
    t.index ["campaign_id"], name: "index_campaigns_regions_on_campaign_id"
    t.index ["region_id"], name: "index_campaigns_regions_on_region_id"
  end

  create_table "cleaning_cost_translations", force: :cascade do |t|
    t.integer "cleaning_cost_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["cleaning_cost_id"], name: "index_cleaning_cost_translations_on_cleaning_cost_id"
    t.index ["locale"], name: "index_cleaning_cost_translations_on_locale"
  end

  create_table "cleaning_costs", force: :cascade do |t|
    t.string "name"
    t.float "fixed_price", default: 0.0
    t.float "price_per_day", default: 0.0
    t.integer "guests"
    t.integer "crm_id"
    t.boolean "manage_by"
    t.bigint "lodging_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lodging_id"], name: "index_cleaning_costs_on_lodging_id"
  end

  create_table "collections", force: :cascade do |t|
    t.bigint "parent_id"
    t.bigint "relative_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_collections_on_parent_id"
    t.index ["relative_id"], name: "index_collections_on_relative_id"
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
    t.string "thumbnails", default: [], array: true
    t.string "images", default: [], array: true
    t.integer "boost", default: 0
  end

  create_table "countries_leads", force: :cascade do |t|
    t.bigint "lead_id"
    t.bigint "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_countries_leads_on_country_id"
    t.index ["lead_id"], name: "index_countries_leads_on_lead_id"
  end

  create_table "country_translations", force: :cascade do |t|
    t.integer "country_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.text "content"
    t.string "slug"
    t.string "title"
    t.string "meta_title"
    t.index ["country_id"], name: "index_country_translations_on_country_id"
    t.index ["locale"], name: "index_country_translations_on_locale"
  end

  create_table "custom_text_translations", force: :cascade do |t|
    t.integer "custom_text_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "h1_text"
    t.text "p_text"
    t.text "meta_title"
    t.text "meta_description"
    t.string "category"
    t.string "seo_path"
    t.string "menu_title"
    t.index ["custom_text_id"], name: "index_custom_text_translations_on_custom_text_id"
    t.index ["locale"], name: "index_custom_text_translations_on_locale"
  end

  create_table "custom_texts", force: :cascade do |t|
    t.integer "crm_id"
    t.text "h1_text"
    t.text "p_text"
    t.text "meta_title"
    t.text "meta_description"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "country_id"
    t.bigint "region_id"
    t.bigint "experience_id"
    t.boolean "homepage", default: false
    t.boolean "country_page", default: false
    t.boolean "region_page", default: false
    t.boolean "navigation_popular", default: false
    t.boolean "navigation_country", default: false
    t.string "image"
    t.string "seo_path"
    t.string "menu_title"
    t.boolean "inspiration", default: false
    t.boolean "popular", default: false
    t.boolean "show_page", default: false
    t.boolean "special_offer", default: false
    t.index ["country_id"], name: "index_custom_texts_on_country_id"
    t.index ["experience_id"], name: "index_custom_texts_on_experience_id"
    t.index ["region_id"], name: "index_custom_texts_on_region_id"
  end

  create_table "discounts", force: :cascade do |t|
    t.bigint "lodging_id"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.string "short_desc"
    t.boolean "publish", default: false
    t.string "discount_type", default: "percentage"
    t.datetime "valid_to"
    t.integer "minimum_days", default: [], array: true
    t.integer "value"
    t.integer "crm_id"
    t.integer "guests"
    t.index ["lodging_id"], name: "index_discounts_on_lodging_id"
  end

  create_table "experience_translations", force: :cascade do |t|
    t.integer "experience_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "slug"
    t.index ["experience_id"], name: "index_experience_translations_on_experience_id"
    t.index ["locale"], name: "index_experience_translations_on_locale"
  end

  create_table "experiences", force: :cascade do |t|
    t.string "name"
    t.string "tag"
    t.string "slug"
    t.text "short_desc"
    t.boolean "publish"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "leads", force: :cascade do |t|
    t.date "from"
    t.date "to"
    t.text "extra_information"
    t.string "slug"
    t.integer "status", default: 0
    t.integer "generated", default: 0
    t.integer "lead_type", default: 0
    t.integer "default_status", default: 0
    t.integer "adults", default: 1
    t.integer "childrens", default: 0
    t.string "created_by"
    t.text "notes"
    t.datetime "offer_date"
    t.string "preferred_country"
    t.string "preferred_accommodations"
    t.string "potential"
    t.text "offer_text"
    t.boolean "publish", default: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_leads_on_user_id"
  end

  create_table "lodging_translations", force: :cascade do |t|
    t.integer "lodging_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "subtitle"
    t.text "description"
    t.text "meta_desc"
    t.string "slug"
    t.string "h1"
    t.string "h2"
    t.string "h3"
    t.string "highlight_1"
    t.string "highlight_2"
    t.string "highlight_3"
    t.text "summary"
    t.text "short_desc"
    t.text "location_description"
    t.string "meta_title"
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
    t.boolean "flexible_arrival", default: false
    t.boolean "listed_to", default: false
    t.boolean "ical_validated", default: false
    t.datetime "route_updated_at"
    t.datetime "price_updated_at"
    t.integer "status"
    t.string "images", default: [], array: true
    t.datetime "crm_synced_at"
    t.bigint "parent_id"
    t.integer "presentation", default: 1
    t.string "thumbnails", default: [], array: true
    t.float "setting", default: 0.0
    t.float "quality", default: 0.0
    t.float "interior", default: 0.0
    t.float "communication", default: 0.0
    t.float "service", default: 0.0
    t.float "average_rating", default: 0.0
    t.string "check_in_day"
    t.integer "minimum_adults", default: 1
    t.integer "minimum_children", default: 0
    t.integer "minimum_infants", default: 0
    t.boolean "home_page", default: false
    t.boolean "region_page", default: false
    t.boolean "country_page", default: false
    t.string "attachments", default: [], array: true
    t.integer "boost", default: 0
    t.datetime "optimize_at"
    t.boolean "confirmed_price_2020", default: false
    t.string "guest_centric_id"
    t.boolean "guest_centric", default: false
    t.index ["owner_id"], name: "index_lodgings_on_owner_id"
    t.index ["parent_id"], name: "index_lodgings_on_parent_id"
    t.index ["region_id"], name: "index_lodgings_on_region_id"
  end

  create_table "lodgings_amenities", force: :cascade do |t|
    t.bigint "lodging_id"
    t.bigint "amenity_id"
    t.index ["amenity_id"], name: "index_lodgings_amenities_on_amenity_id"
    t.index ["lodging_id"], name: "index_lodgings_amenities_on_lodging_id"
  end

  create_table "lodgings_experiences", force: :cascade do |t|
    t.bigint "lodging_id"
    t.bigint "experience_id"
    t.index ["experience_id"], name: "index_lodgings_experiences_on_experience_id"
    t.index ["lodging_id"], name: "index_lodgings_experiences_on_lodging_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "read_at"
    t.string "action"
    t.integer "notifiable_id"
    t.string "notifiable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_id", "notifiable_type"], name: "index_notifications_on_notifiable_id_and_notifiable_type"
    t.index ["user_id"], name: "index_notifications_on_user_id"
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
    t.bigint "admin_user_id"
    t.index ["admin_user_id"], name: "index_owners_on_admin_user_id"
    t.index ["email"], name: "index_owners_on_email", unique: true
    t.index ["reset_password_token"], name: "index_owners_on_reset_password_token", unique: true
  end

  create_table "page_translations", force: :cascade do |t|
    t.integer "page_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "meta_title"
    t.text "short_desc"
    t.text "content"
    t.string "category"
    t.string "slug"
    t.index ["locale"], name: "index_page_translations_on_locale"
    t.index ["page_id"], name: "index_page_translations_on_page_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "title"
    t.string "meta_title"
    t.text "short_desc"
    t.text "content"
    t.string "category"
    t.string "slug"
    t.boolean "header_dropdown", default: false
    t.boolean "rating_box", default: false
    t.boolean "homepage", default: false
    t.string "images", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "place_categories", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "color_code", default: "#7D3C98"
  end

  create_table "place_category_translations", force: :cascade do |t|
    t.integer "place_category_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "slug"
    t.index ["locale"], name: "index_place_category_translations_on_locale"
    t.index ["place_category_id"], name: "index_place_category_translations_on_place_category_id"
  end

  create_table "place_translations", force: :cascade do |t|
    t.integer "place_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "details"
    t.text "description"
    t.string "name"
    t.string "slug"
    t.index ["locale"], name: "index_place_translations_on_locale"
    t.index ["place_id"], name: "index_place_translations_on_place_id"
  end

  create_table "places", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.text "details"
    t.text "description"
    t.string "slug"
    t.boolean "spotlight"
    t.boolean "header_dropdown"
    t.text "short_desc"
    t.string "short_desc_nav"
    t.string "images", default: [], array: true
    t.float "latitude"
    t.float "longitude"
    t.bigint "country_id"
    t.bigint "region_id"
    t.bigint "place_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "publish", default: true
    t.index ["country_id"], name: "index_places_on_country_id"
    t.index ["place_category_id"], name: "index_places_on_place_category_id"
    t.index ["region_id"], name: "index_places_on_region_id"
  end

  create_table "price_text_translations", force: :cascade do |t|
    t.integer "price_text_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "season_text"
    t.text "including_text"
    t.text "pay_text"
    t.text "deposit_text"
    t.text "options_text"
    t.text "particularities_text"
    t.text "payment_terms_text"
    t.index ["locale"], name: "index_price_text_translations_on_locale"
    t.index ["price_text_id"], name: "index_price_text_translations_on_price_text_id"
  end

  create_table "price_texts", force: :cascade do |t|
    t.text "season_text"
    t.text "including_text"
    t.text "pay_text"
    t.text "deposit_text"
    t.text "options_text"
    t.text "particularities_text"
    t.text "payment_terms_text"
    t.bigint "lodging_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lodging_id"], name: "index_price_texts_on_lodging_id"
  end

  create_table "prices", force: :cascade do |t|
    t.float "amount", default: 0.0
    t.bigint "availability_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "weekly_price"
    t.text "adults", default: [], array: true
    t.text "children", default: [], array: true
    t.text "infants", default: [], array: true
    t.text "minimum_stay", default: [], array: true
    t.index ["availability_id"], name: "index_prices_on_availability_id"
  end

  create_table "region_translations", force: :cascade do |t|
    t.integer "region_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.text "content"
    t.string "slug"
    t.string "title"
    t.string "meta_title"
    t.index ["locale"], name: "index_region_translations_on_locale"
    t.index ["region_id"], name: "index_region_translations_on_region_id"
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
    t.string "thumbnails", default: [], array: true
    t.string "images", default: [], array: true
    t.index ["country_id"], name: "index_regions_on_country_id"
  end

  create_table "reservations", force: :cascade do |t|
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
    t.integer "crm_booking_id"
    t.boolean "in_cart", default: true
    t.bigint "lodging_id"
    t.bigint "booking_id"
    t.boolean "canceled", default: false
    t.string "booked_by"
    t.index ["booking_id"], name: "index_reservations_on_booking_id"
    t.index ["lodging_id"], name: "index_reservations_on_lodging_id"
  end

  create_table "review_translations", force: :cascade do |t|
    t.integer "review_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "suggetion"
    t.text "description"
    t.index ["locale"], name: "index_review_translations_on_locale"
    t.index ["review_id"], name: "index_review_translations_on_review_id"
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
    t.string "thumbnails", default: [], array: true
    t.string "images", default: [], array: true
    t.boolean "published", default: false
    t.boolean "perfect", default: false
    t.boolean "anonymous", default: false
    t.boolean "client_published", default: true
    t.text "nice2stay_feedback"
    t.index ["lodging_id"], name: "index_reviews_on_lodging_id"
    t.index ["reservation_id"], name: "index_reviews_on_reservation_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "rules", force: :cascade do |t|
    t.bigint "lodging_id"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "flexible_arrival", default: false
    t.integer "minimum_stay"
    t.index ["lodging_id"], name: "index_rules_on_lodging_id"
  end

  create_table "social_logins", force: :cascade do |t|
    t.string "provider"
    t.string "uid"
    t.string "email"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.index ["confirmation_token"], name: "index_social_logins_on_confirmation_token", unique: true
    t.index ["user_id"], name: "index_social_logins_on_user_id"
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
    t.string "token_expires_at"
    t.integer "creation_status", default: 0
    t.string "image"
    t.string "mollie_id"
    t.string "address"
    t.string "city"
    t.string "zipcode"
    t.string "phone"
    t.string "language"
    t.bigint "country_id"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["country_id"], name: "index_users_on_country_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wishlists", force: :cascade do |t|
    t.bigint "lodging_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "check_in"
    t.date "check_out"
    t.integer "adults"
    t.integer "children"
    t.string "name"
    t.text "notes"
    t.integer "status", default: 0
    t.index ["lodging_id"], name: "index_wishlists_on_lodging_id"
    t.index ["user_id"], name: "index_wishlists_on_user_id"
  end

  add_foreign_key "availabilities", "lodgings", on_delete: :cascade
  add_foreign_key "bookings", "users", on_delete: :cascade
  add_foreign_key "campaigns_regions", "campaigns", on_delete: :cascade
  add_foreign_key "campaigns_regions", "regions", on_delete: :cascade
  add_foreign_key "cleaning_costs", "lodgings", on_delete: :cascade
  add_foreign_key "collections", "custom_texts", column: "parent_id", on_delete: :cascade
  add_foreign_key "collections", "custom_texts", column: "relative_id", on_delete: :cascade
  add_foreign_key "countries_leads", "countries", on_delete: :cascade
  add_foreign_key "countries_leads", "leads", on_delete: :cascade
  add_foreign_key "custom_texts", "countries", on_delete: :cascade
  add_foreign_key "custom_texts", "experiences", on_delete: :cascade
  add_foreign_key "custom_texts", "regions", on_delete: :cascade
  add_foreign_key "discounts", "lodgings", on_delete: :cascade
  add_foreign_key "leads", "users", on_delete: :cascade
  add_foreign_key "lodgings", "owners", on_delete: :cascade
  add_foreign_key "lodgings", "regions", on_delete: :cascade
  add_foreign_key "lodgings_amenities", "amenities", on_delete: :cascade
  add_foreign_key "lodgings_amenities", "lodgings", on_delete: :cascade
  add_foreign_key "lodgings_experiences", "experiences", on_delete: :cascade
  add_foreign_key "lodgings_experiences", "lodgings", on_delete: :cascade
  add_foreign_key "notifications", "users", on_delete: :cascade
  add_foreign_key "owners", "admin_users"
  add_foreign_key "places", "countries", on_delete: :cascade
  add_foreign_key "places", "place_categories", on_delete: :cascade
  add_foreign_key "places", "regions", on_delete: :cascade
  add_foreign_key "price_texts", "lodgings", on_delete: :cascade
  add_foreign_key "prices", "availabilities", on_delete: :cascade
  add_foreign_key "regions", "countries", on_delete: :cascade
  add_foreign_key "reservations", "bookings", on_delete: :cascade
  add_foreign_key "reservations", "lodgings", on_delete: :cascade
  add_foreign_key "reviews", "lodgings", on_delete: :cascade
  add_foreign_key "reviews", "reservations", on_delete: :cascade
  add_foreign_key "reviews", "users", on_delete: :cascade
  add_foreign_key "rules", "lodgings", on_delete: :cascade
  add_foreign_key "social_logins", "users", on_delete: :cascade
  add_foreign_key "specifications", "lodgings", on_delete: :cascade
  add_foreign_key "users", "countries"
  add_foreign_key "wishlists", "lodgings", on_delete: :cascade
  add_foreign_key "wishlists", "users", on_delete: :cascade
end
