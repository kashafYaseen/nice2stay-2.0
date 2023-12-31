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

ActiveRecord::Schema.define(version: 2023_08_08_122510) do

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
    t.string "token_expires_at"
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
    t.string "icon"
    t.bigint "amenity_category_id"
    t.integer "crm_id"
    t.string "image"
    t.boolean "parent", default: false
    t.index ["amenity_category_id"], name: "index_amenities_on_amenity_category_id"
  end

  create_table "amenity_categories", force: :cascade do |t|
    t.string "name"
    t.integer "crm_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "amenity_category_translations", force: :cascade do |t|
    t.integer "amenity_category_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["amenity_category_id"], name: "index_amenity_category_translations_on_amenity_category_id"
    t.index ["locale"], name: "index_amenity_category_translations_on_locale"
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
    t.string "minimum_stay", default: [], array: true
    t.boolean "check_in_closed", default: false
    t.boolean "check_out_closed", default: false
    t.integer "booking_limit", default: 0
    t.bigint "room_rate_id"
    t.index ["lodging_id", "available_on"], name: "index_availabilities_on_lodging_id_and_available_on", unique: true
    t.index ["lodging_id"], name: "index_availabilities_on_lodging_id"
    t.index ["room_rate_id"], name: "index_availabilities_on_room_rate_id"
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
    t.date "final_payment_till"
    t.date "free_cancelation_till"
    t.boolean "free_cancelation", default: false
    t.boolean "rebooked", default: false
    t.boolean "rebooking_approved", default: false
    t.string "voucher_code"
    t.float "voucher_amount"
    t.string "security_deposit_payment_mollie_id"
    t.datetime "security_payed_at"
    t.string "owner_name", default: ""
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
    t.integer "region_id"
    t.integer "country_id"
    t.float "min_price"
    t.float "max_price"
    t.datetime "from"
    t.datetime "to"
    t.text "category"
    t.boolean "footer", default: false
    t.boolean "top_menu", default: false
    t.boolean "homepage", default: false
  end

  create_table "campaigns_regions", force: :cascade do |t|
    t.bigint "campaign_id"
    t.bigint "region_id"
    t.index ["campaign_id"], name: "index_campaigns_regions_on_campaign_id"
    t.index ["region_id"], name: "index_campaigns_regions_on_region_id"
  end

  create_table "cancellation_policies", force: :cascade do |t|
    t.integer "cancellation_percentage"
    t.integer "days_prior_to_check_in"
    t.integer "crm_id"
    t.bigint "rate_plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cancellation_type"
    t.index ["rate_plan_id"], name: "index_cancellation_policies_on_rate_plan_id"
  end

  create_table "child_rates", force: :cascade do |t|
    t.integer "open_gds_category"
    t.decimal "rate"
    t.integer "rate_type"
    t.bigint "rate_plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "age_group"
    t.index ["rate_plan_id"], name: "index_child_rates_on_rate_plan_id"
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
    t.bigint "availability_id"
    t.index ["availability_id"], name: "index_cleaning_costs_on_availability_id"
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
    t.string "code"
    t.integer "crm_id"
    t.index ["crm_id"], name: "index_countries_on_crm_id", unique: true
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
    t.integer "crm_id"
    t.integer "priority", default: 2
    t.integer "guests", default: 999
    t.string "image"
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

  create_table "gc_offer_translations", force: :cascade do |t|
    t.integer "gc_offer_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.text "short_description"
    t.text "description"
    t.text "policy"
    t.text "restrictions"
    t.index ["gc_offer_id"], name: "index_gc_offer_translations_on_gc_offer_id"
    t.index ["locale"], name: "index_gc_offer_translations_on_locale"
  end

  create_table "gc_offers", force: :cascade do |t|
    t.string "name"
    t.string "offer_id"
    t.text "short_description"
    t.text "description"
    t.bigint "lodging_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "policy"
    t.text "restrictions"
    t.index ["lodging_id"], name: "index_gc_offers_on_lodging_id"
  end

  create_table "guest_details", force: :cascade do |t|
    t.string "name"
    t.datetime "date_of_birth"
    t.integer "age"
    t.string "guest_type"
    t.bigint "reservation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reservation_id"], name: "index_guest_details_on_reservation_id"
  end

  create_table "lead_translations", force: :cascade do |t|
    t.integer "lead_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "notes"
    t.text "email_intro"
    t.index ["lead_id"], name: "index_lead_translations_on_lead_id"
    t.index ["locale"], name: "index_lead_translations_on_locale"
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
    t.bigint "admin_user_id"
    t.text "email_intro"
    t.integer "stay"
    t.integer "experience"
    t.integer "budget"
    t.string "preferred_months"
    t.index ["admin_user_id"], name: "index_leads_on_admin_user_id"
    t.index ["user_id"], name: "index_leads_on_user_id"
  end

  create_table "leads_regions", force: :cascade do |t|
    t.bigint "lead_id"
    t.bigint "region_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_id"], name: "index_leads_regions_on_lead_id"
    t.index ["region_id"], name: "index_leads_regions_on_region_id"
  end

  create_table "linked_supplements", force: :cascade do |t|
    t.string "supplementable_type"
    t.bigint "supplementable_id"
    t.bigint "supplement_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["supplement_id"], name: "index_linked_supplements_on_supplement_id"
    t.index ["supplementable_type", "supplementable_id"], name: "index_linked_supplements_on_supplementable"
  end

  create_table "lodging_categories", force: :cascade do |t|
    t.string "name"
    t.integer "crm_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lodging_category_translations", force: :cascade do |t|
    t.bigint "lodging_category_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["locale"], name: "index_lodging_category_translations_on_locale"
    t.index ["lodging_category_id"], name: "index_lodging_category_translations_on_lodging_category_id"
  end

  create_table "lodging_place_categories", force: :cascade do |t|
    t.bigint "lodging_id"
    t.bigint "place_category_id"
    t.index ["lodging_id"], name: "index_lodging_place_categories_on_lodging_id"
    t.index ["place_category_id"], name: "index_lodging_place_categories_on_place_category_id"
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
    t.boolean "realtime_availability", default: false
    t.string "gc_username"
    t.string "gc_password"
    t.string "gc_rooms", default: [], array: true
    t.integer "crm_id"
    t.boolean "free_cancelation", default: false
    t.boolean "dynamic_prices", default: false
    t.string "ical"
    t.string "be_category_id"
    t.string "be_admin_id"
    t.string "be_org_id"
    t.boolean "booking_expert", default: false
    t.bigint "room_type_id"
    t.integer "channel", default: 0
    t.integer "open_gds_property_id"
    t.string "open_gds_accommodation_id"
    t.integer "extra_beds", default: 0
    t.boolean "extra_beds_for_children_only", default: false
    t.integer "num_of_accommodations", default: 1
    t.string "name_on_cm"
    t.float "deposit"
    t.bigint "lodging_category_id"
    t.index ["crm_id"], name: "index_lodgings_on_crm_id", unique: true
    t.index ["lodging_category_id"], name: "index_lodgings_on_lodging_category_id"
    t.index ["owner_id"], name: "index_lodgings_on_owner_id"
    t.index ["parent_id"], name: "index_lodgings_on_parent_id"
    t.index ["region_id"], name: "index_lodgings_on_region_id"
    t.index ["room_type_id"], name: "index_lodgings_on_room_type_id"
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

  create_table "meal_translations", force: :cascade do |t|
    t.integer "meal_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.string "name"
    t.index ["locale"], name: "index_meal_translations_on_locale"
    t.index ["meal_id"], name: "index_meal_translations_on_meal_id"
  end

  create_table "meals", force: :cascade do |t|
    t.integer "gc_meal_id"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
  end

  create_table "newsletter_subscriptions", force: :cascade do |t|
    t.string "email"
    t.string "language"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
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

  create_table "offer_lodgings", force: :cascade do |t|
    t.bigint "offer_id"
    t.bigint "lodging_id"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lodging_id"], name: "index_offer_lodgings_on_lodging_id"
    t.index ["offer_id"], name: "index_offer_lodgings_on_offer_id"
  end

  create_table "offers", force: :cascade do |t|
    t.date "from"
    t.date "to"
    t.integer "adults", default: 1
    t.integer "childrens", default: 0
    t.text "notes"
    t.bigint "lead_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.index ["lead_id"], name: "index_offers_on_lead_id"
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
    t.integer "pre_payment", default: 30
    t.integer "final_payment", default: 70
    t.string "token_expires_at"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.bigint "invited_by_id"
    t.string "invited_by_type"
    t.integer "invitations_count", default: 0
    t.string "business_name"
    t.integer "account_id"
    t.boolean "email_boolean", default: false
    t.boolean "not_interested", default: false
    t.string "language"
    t.boolean "updating_availability", default: false
    t.boolean "automated_availability", default: false
    t.bigint "country_id"
    t.bigint "region_id"
    t.index ["admin_user_id"], name: "index_owners_on_admin_user_id"
    t.index ["country_id"], name: "index_owners_on_country_id"
    t.index ["email"], name: "index_owners_on_email", unique: true
    t.index ["invited_by_id"], name: "index_owners_on_invited_by_id"
    t.index ["region_id"], name: "index_owners_on_region_id"
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
    t.boolean "private", default: false
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
    t.integer "checkin", default: 0
    t.decimal "open_gds_single_rate", default: "0.0"
    t.string "multiple_checkin_days", default: [], array: true
    t.boolean "rr_additional_amount_flag", default: false
    t.index ["availability_id"], name: "index_prices_on_availability_id"
  end

  create_table "rate_plan_translations", force: :cascade do |t|
    t.string "locale"
    t.string "name"
    t.text "description"
    t.bigint "rate_plan_id"
    t.index ["rate_plan_id"], name: "index_rate_plan_translations_on_rate_plan_id"
  end

  create_table "rate_plans", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "price", default: "0.0"
    t.text "description"
    t.integer "open_gds_rate_id"
    t.boolean "rate_enabled", default: false
    t.boolean "open_gds_valid_permanent", default: false
    t.decimal "open_gds_res_fee", default: "0.0"
    t.integer "open_gds_rate_type"
    t.integer "min_stay", default: 1
    t.integer "max_stay", default: 45
    t.text "open_gds_daily_supplements"
    t.integer "open_gds_single_rate_type"
    t.datetime "opengds_pushed_at"
    t.bigint "parent_lodging_id"
    t.bigint "crm_id"
    t.string "name_on_cm"
    t.integer "min_occupancy"
    t.integer "max_occupancy"
    t.integer "pre_payment_percentage"
    t.integer "pre_payment_hours_limit"
    t.integer "final_payment_days_limit"
    t.index ["parent_lodging_id"], name: "index_rate_plans_on_parent_lodging_id"
  end

  create_table "recent_searches", force: :cascade do |t|
    t.date "check_in"
    t.date "check_out"
    t.integer "adults"
    t.integer "children"
    t.integer "infants"
    t.bigint "searchable_id"
    t.string "searchable_type"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_id", "searchable_type"], name: "index_recent_searches_on_searchable_id_and_searchable_type"
    t.index ["user_id"], name: "index_recent_searches_on_user_id"
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
    t.integer "crm_id"
    t.boolean "published", default: false
    t.index ["country_id", "name"], name: "index_regions_on_country_id_and_name", unique: true
    t.index ["country_id"], name: "index_regions_on_country_id"
    t.index ["crm_id"], name: "index_regions_on_crm_id", unique: true
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
    t.string "guest_centric_booking_id"
    t.string "offer_id"
    t.string "meal_id"
    t.float "meal_price", default: 0.0
    t.text "gc_errors"
    t.integer "rooms", default: 1
    t.float "meal_tax", default: 0.0
    t.float "tax", default: 0.0
    t.float "additional_fee", default: 0.0
    t.string "room_type"
    t.text "gc_policy"
    t.date "expired_at"
    t.integer "book_option", default: 0
    t.integer "cancel_option_reason", default: -1
    t.string "canceled_by"
    t.string "be_category_id"
    t.string "channel_manager_booking_id"
    t.text "channel_manager_errors"
    t.text "rr_errors"
    t.integer "rr_res_id_value"
    t.bigint "room_rate_id"
    t.string "open_gds_res_id"
    t.string "open_gds_error_name"
    t.string "open_gds_error_message"
    t.integer "open_gds_error_code"
    t.integer "open_gds_error_status"
    t.boolean "open_gds_online_payment", default: false
    t.string "open_gds_payment_hash"
    t.decimal "open_gds_deposit_amount", default: "0.0"
    t.integer "open_gds_payment_status", default: 0
    t.datetime "canceled_at_channel"
    t.decimal "pre_payment_percentage", default: "30.0"
    t.decimal "final_payment_percentage", default: "70.0"
    t.boolean "payment_in_percentage", default: true
    t.float "security_deposit"
    t.boolean "include_deposit"
    t.float "commission", default: 0.0
    t.index ["booking_id"], name: "index_reservations_on_booking_id"
    t.index ["lodging_id"], name: "index_reservations_on_lodging_id"
    t.index ["room_rate_id"], name: "index_reservations_on_room_rate_id"
  end

  create_table "reserved_supplements", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "supplement_type", default: 0
    t.integer "rate_type", default: 0
    t.decimal "rate", default: "0.0"
    t.decimal "child_rate", default: "0.0"
    t.decimal "total", default: "0.0"
    t.bigint "reservation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity", default: 0
    t.index ["reservation_id"], name: "index_reserved_supplements_on_reservation_id"
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

  create_table "room_rates", force: :cascade do |t|
    t.integer "default_booking_limit", default: 0
    t.decimal "default_rate", default: "0.0"
    t.string "currency_code"
    t.decimal "default_single_rate", default: "0.0"
    t.integer "default_single_rate_type"
    t.integer "extra_bed_rate_type", default: 0
    t.decimal "extra_bed_rate"
    t.decimal "extra_night_rate"
    t.bigint "room_type_id"
    t.bigint "rate_plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "child_lodging_id"
    t.boolean "publish", default: true
    t.index ["child_lodging_id"], name: "index_room_rates_on_child_lodging_id"
    t.index ["rate_plan_id"], name: "index_room_rates_on_rate_plan_id"
    t.index ["room_type_id"], name: "index_room_rates_on_room_type_id"
  end

  create_table "room_types", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.bigint "parent_lodging_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_lodging_id"], name: "index_room_types_on_parent_lodging_id"
  end

  create_table "rules", force: :cascade do |t|
    t.bigint "lodging_id"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "flexible_arrival", default: false
    t.integer "minimum_stay", default: [], array: true
    t.string "checkin_day"
    t.integer "open_gds_restriction_type"
    t.integer "open_gds_restriction_days", default: 0
    t.string "open_gds_arrival_days", default: [], array: true
    t.bigint "rate_plan_id"
    t.index ["lodging_id"], name: "index_rules_on_lodging_id"
    t.index ["rate_plan_id"], name: "index_rules_on_rate_plan_id"
  end

  create_table "search_analytics", force: :cascade do |t|
    t.text "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "supplement_translations", force: :cascade do |t|
    t.string "locale"
    t.string "name"
    t.text "description"
    t.bigint "crm_id"
    t.bigint "supplement_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["supplement_id"], name: "index_supplement_translations_on_supplement_id"
  end

  create_table "supplements", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "supplement_type", default: 0
    t.integer "rate_type"
    t.decimal "rate"
    t.decimal "child_rate"
    t.integer "maximum_number", default: 0
    t.boolean "published", default: false
    t.boolean "valid_permanent", default: false
    t.datetime "valid_from"
    t.datetime "valid_till"
    t.string "valid_on_arrival_days", default: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], array: true
    t.string "valid_on_departure_days", default: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], array: true
    t.string "valid_on_stay_days", default: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], array: true
    t.bigint "crm_id"
    t.bigint "lodging_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lodging_id"], name: "index_supplements_on_lodging_id"
  end

  create_table "trip_members", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "trip_id"
    t.boolean "admin", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_id"], name: "index_trip_members_on_trip_id"
    t.index ["user_id"], name: "index_trip_members_on_user_id"
  end

  create_table "trips", force: :cascade do |t|
    t.string "name"
    t.integer "adults", default: 1
    t.integer "children", default: 0
    t.float "budget", default: 0.0
    t.date "check_in"
    t.date "check_out"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "visibility", default: 0
    t.boolean "need_advise", default: false
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
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.integer "referral"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["country_id"], name: "index_users_on_country_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "visited_lodgings", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "lodging_id", null: false
    t.index ["user_id", "lodging_id"], name: "index_visited_lodgings_on_user_id_and_lodging_id"
  end

  create_table "vouchers", force: :cascade do |t|
    t.string "sender_name"
    t.string "sender_email"
    t.integer "amount"
    t.boolean "send_by_post", default: false
    t.text "message"
    t.bigint "receiver_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "receiver_city"
    t.string "receiver_zipcode"
    t.string "receiver_address"
    t.bigint "receiver_country_id"
    t.string "code"
    t.boolean "used", default: false
    t.datetime "expired_at"
    t.string "sender_mollie_id"
    t.string "payment_status"
    t.datetime "payed_at"
    t.float "mollie_amount", default: 0.0
    t.string "mollie_payment_id"
    t.integer "created_by", default: 0
    t.integer "crm_id"
    t.index ["receiver_country_id"], name: "index_vouchers_on_receiver_country_id"
    t.index ["receiver_id"], name: "index_vouchers_on_receiver_id"
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
    t.bigint "trip_id"
    t.index ["lodging_id"], name: "index_wishlists_on_lodging_id"
    t.index ["trip_id"], name: "index_wishlists_on_trip_id"
    t.index ["user_id"], name: "index_wishlists_on_user_id"
  end

  add_foreign_key "amenities", "amenity_categories", on_delete: :cascade
  add_foreign_key "availabilities", "lodgings", on_delete: :cascade
  add_foreign_key "availabilities", "room_rates", on_delete: :cascade
  add_foreign_key "bookings", "users", on_delete: :cascade
  add_foreign_key "campaigns_regions", "campaigns", on_delete: :cascade
  add_foreign_key "campaigns_regions", "regions", on_delete: :cascade
  add_foreign_key "cancellation_policies", "rate_plans"
  add_foreign_key "child_rates", "rate_plans", on_delete: :cascade
  add_foreign_key "cleaning_costs", "availabilities", on_delete: :cascade
  add_foreign_key "cleaning_costs", "lodgings", on_delete: :cascade
  add_foreign_key "collections", "custom_texts", column: "parent_id", on_delete: :cascade
  add_foreign_key "collections", "custom_texts", column: "relative_id", on_delete: :cascade
  add_foreign_key "countries_leads", "countries", on_delete: :cascade
  add_foreign_key "countries_leads", "leads", on_delete: :cascade
  add_foreign_key "custom_texts", "countries", on_delete: :cascade
  add_foreign_key "custom_texts", "experiences", on_delete: :cascade
  add_foreign_key "custom_texts", "regions", on_delete: :cascade
  add_foreign_key "discounts", "lodgings", on_delete: :cascade
  add_foreign_key "gc_offers", "lodgings", on_delete: :cascade
  add_foreign_key "guest_details", "reservations", on_delete: :cascade
  add_foreign_key "leads", "admin_users"
  add_foreign_key "leads", "users", on_delete: :cascade
  add_foreign_key "leads_regions", "leads", on_delete: :cascade
  add_foreign_key "leads_regions", "regions", on_delete: :cascade
  add_foreign_key "linked_supplements", "supplements", on_delete: :cascade
  add_foreign_key "lodging_place_categories", "lodgings", on_delete: :cascade
  add_foreign_key "lodging_place_categories", "place_categories", on_delete: :cascade
  add_foreign_key "lodgings", "lodging_categories"
  add_foreign_key "lodgings", "owners", on_delete: :cascade
  add_foreign_key "lodgings", "regions", on_delete: :cascade
  add_foreign_key "lodgings_amenities", "amenities", on_delete: :cascade
  add_foreign_key "lodgings_amenities", "lodgings", on_delete: :cascade
  add_foreign_key "lodgings_experiences", "experiences", on_delete: :cascade
  add_foreign_key "lodgings_experiences", "lodgings", on_delete: :cascade
  add_foreign_key "notifications", "users", on_delete: :cascade
  add_foreign_key "offer_lodgings", "lodgings", on_delete: :cascade
  add_foreign_key "offer_lodgings", "offers", on_delete: :cascade
  add_foreign_key "offers", "leads", on_delete: :cascade
  add_foreign_key "owners", "admin_users"
  add_foreign_key "owners", "admin_users", column: "invited_by_id"
  add_foreign_key "owners", "countries"
  add_foreign_key "owners", "regions"
  add_foreign_key "places", "countries", on_delete: :cascade
  add_foreign_key "places", "place_categories", on_delete: :cascade
  add_foreign_key "places", "regions", on_delete: :cascade
  add_foreign_key "price_texts", "lodgings", on_delete: :cascade
  add_foreign_key "prices", "availabilities", on_delete: :cascade
  add_foreign_key "rate_plan_translations", "rate_plans", on_delete: :cascade
  add_foreign_key "rate_plans", "lodgings", column: "parent_lodging_id", on_delete: :cascade
  add_foreign_key "recent_searches", "users", on_delete: :cascade
  add_foreign_key "regions", "countries", on_delete: :cascade
  add_foreign_key "reservations", "bookings", on_delete: :cascade
  add_foreign_key "reservations", "lodgings", on_delete: :cascade
  add_foreign_key "reservations", "room_rates", on_delete: :nullify
  add_foreign_key "reserved_supplements", "reservations", on_delete: :cascade
  add_foreign_key "reviews", "lodgings", on_delete: :cascade
  add_foreign_key "reviews", "reservations", on_delete: :cascade
  add_foreign_key "reviews", "users", on_delete: :cascade
  add_foreign_key "room_rates", "lodgings", column: "child_lodging_id", on_delete: :cascade
  add_foreign_key "room_rates", "rate_plans", on_delete: :cascade
  add_foreign_key "room_rates", "room_types", on_delete: :cascade
  add_foreign_key "room_types", "lodgings", column: "parent_lodging_id", on_delete: :cascade
  add_foreign_key "rules", "lodgings", on_delete: :cascade
  add_foreign_key "rules", "rate_plans", on_delete: :cascade
  add_foreign_key "social_logins", "users", on_delete: :cascade
  add_foreign_key "specifications", "lodgings", on_delete: :cascade
  add_foreign_key "supplement_translations", "supplements", on_delete: :cascade
  add_foreign_key "supplements", "lodgings", on_delete: :cascade
  add_foreign_key "trip_members", "trips", on_delete: :cascade
  add_foreign_key "trip_members", "users", on_delete: :cascade
  add_foreign_key "users", "countries"
  add_foreign_key "vouchers", "countries", column: "receiver_country_id"
  add_foreign_key "vouchers", "users", column: "receiver_id", on_delete: :cascade
  add_foreign_key "wishlists", "lodgings", on_delete: :cascade
  add_foreign_key "wishlists", "trips", on_delete: :cascade
  add_foreign_key "wishlists", "users", on_delete: :cascade
end
