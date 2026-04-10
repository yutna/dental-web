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

ActiveRecord::Schema[8.1].define(version: 2026_04_10_165000) do
  create_table "clinic_services", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.integer "default_duration_minutes", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_clinic_services_on_code", unique: true
  end

  create_table "dental_admin_audit_events", force: :cascade do |t|
    t.string "action", null: false
    t.string "actor_id", null: false
    t.datetime "created_at", null: false
    t.text "metadata_json", default: "{}", null: false
    t.integer "resource_id"
    t.string "resource_type", null: false
    t.index ["action"], name: "index_dental_admin_audit_events_on_action"
    t.index ["actor_id"], name: "index_dental_admin_audit_events_on_actor_id"
    t.index ["created_at"], name: "index_dental_admin_audit_events_on_created_at"
    t.index ["resource_type", "resource_id"], name: "index_dental_admin_audit_events_on_resource"
  end

  create_table "dental_image_type_references", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_dental_image_type_references_on_code", unique: true
  end

  create_table "dental_master_data_change_requests", force: :cascade do |t|
    t.datetime "approved_at"
    t.string "approved_by_id"
    t.string "change_type", null: false
    t.datetime "created_at", null: false
    t.text "payload_json", null: false
    t.string "requested_by_id", null: false
    t.integer "resource_id", null: false
    t.string "resource_type", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["resource_type", "resource_id"], name: "index_dental_md_change_requests_on_resource"
    t.index ["status"], name: "index_dental_master_data_change_requests_on_status"
  end

  create_table "dental_medication_profiles", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "category", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_dental_medication_profiles_on_code", unique: true
  end

  create_table "dental_procedure_groups", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_dental_procedure_groups_on_code", unique: true
  end

  create_table "dental_procedure_item_coverages", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.decimal "copay_amount", precision: 10, scale: 2
    t.decimal "copay_percent", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.date "effective_from", null: false
    t.date "effective_to"
    t.string "eligibility_code", null: false
    t.integer "lock_version", default: 0, null: false
    t.decimal "price_ipd", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "price_opd", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "procedure_item_id", null: false
    t.datetime "updated_at", null: false
    t.index ["procedure_item_id", "eligibility_code", "effective_from"], name: "index_dental_proc_item_coverages_on_item_eligibility_from"
    t.index ["procedure_item_id"], name: "index_dental_procedure_item_coverages_on_procedure_item_id"
  end

  create_table "dental_procedure_items", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.integer "lock_version", default: 0, null: false
    t.string "name", null: false
    t.decimal "price_ipd", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "price_opd", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "procedure_group_id", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_dental_procedure_items_on_code", unique: true
    t.index ["procedure_group_id"], name: "index_dental_procedure_items_on_procedure_group_id"
  end

  create_table "dental_supply_categories", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_dental_supply_categories_on_code", unique: true
  end

  create_table "dental_supply_item_coverages", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.decimal "copay_amount", precision: 10, scale: 2
    t.decimal "copay_percent", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.date "effective_from", null: false
    t.date "effective_to"
    t.string "eligibility_code", null: false
    t.integer "lock_version", default: 0, null: false
    t.integer "supply_item_id", null: false
    t.decimal "unit_price", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["supply_item_id", "eligibility_code", "effective_from"], name: "index_dental_supply_item_coverages_on_item_eligibility_from"
    t.index ["supply_item_id"], name: "index_dental_supply_item_coverages_on_supply_item_id"
  end

  create_table "dental_supply_items", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "supply_category_id", null: false
    t.string "unit", null: false
    t.decimal "unit_price", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_dental_supply_items_on_code", unique: true
    t.index ["supply_category_id"], name: "index_dental_supply_items_on_supply_category_id"
  end

  create_table "dental_tooth_piece_references", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "sort_order", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_dental_tooth_piece_references_on_code", unique: true
  end

  create_table "dental_tooth_references", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "sort_order", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_dental_tooth_references_on_code", unique: true
  end

  create_table "dental_tooth_root_references", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "sort_order", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_dental_tooth_root_references_on_code", unique: true
  end

  create_table "dental_tooth_surface_references", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "sort_order", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_dental_tooth_surface_references_on_code", unique: true
  end

  create_table "dental_workflow_timeline_entries", force: :cascade do |t|
    t.string "actor_id"
    t.datetime "created_at", null: false
    t.string "event_type", null: false
    t.string "from_stage", null: false
    t.text "metadata_json", default: "{}", null: false
    t.string "to_stage", null: false
    t.string "visit_id", null: false
    t.index ["event_type"], name: "index_dental_workflow_timeline_entries_on_event_type"
    t.index ["visit_id", "created_at"], name: "index_dental_workflow_timeline_on_visit_created"
  end

  add_foreign_key "dental_procedure_item_coverages", "dental_procedure_items", column: "procedure_item_id"
  add_foreign_key "dental_procedure_items", "dental_procedure_groups", column: "procedure_group_id"
  add_foreign_key "dental_supply_item_coverages", "dental_supply_items", column: "supply_item_id"
  add_foreign_key "dental_supply_items", "dental_supply_categories", column: "supply_category_id"
end
