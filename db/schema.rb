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

ActiveRecord::Schema[8.1].define(version: 2026_04_11_160001) do
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
    t.string "event_type", default: "admin"
    t.text "metadata_json", default: "{}", null: false
    t.integer "resource_id"
    t.string "resource_type", null: false
    t.index ["action"], name: "index_dental_admin_audit_events_on_action"
    t.index ["actor_id"], name: "index_dental_admin_audit_events_on_actor_id"
    t.index ["created_at"], name: "index_dental_admin_audit_events_on_created_at"
    t.index ["event_type"], name: "index_dental_admin_audit_events_on_event_type"
    t.index ["resource_type", "resource_id"], name: "index_dental_admin_audit_events_on_resource"
  end

  create_table "dental_clinical_chart_records", force: :cascade do |t|
    t.string "charting_code", null: false
    t.integer "clinical_post_id", null: false
    t.datetime "created_at", null: false
    t.text "note"
    t.datetime "occurred_at", null: false
    t.string "patient_hn", null: false
    t.text "piece_codes_json", default: "[]", null: false
    t.text "root_codes_json", default: "[]", null: false
    t.text "surface_codes_json", default: "[]", null: false
    t.string "tooth_code", null: false
    t.datetime "updated_at", null: false
    t.string "visit_id", null: false
    t.index ["clinical_post_id"], name: "index_dental_clinical_chart_records_on_clinical_post_id"
    t.index ["patient_hn", "tooth_code", "occurred_at"], name: "index_dental_chart_records_on_patient_tooth_time"
  end

  create_table "dental_clinical_image_records", force: :cascade do |t|
    t.datetime "captured_at", null: false
    t.integer "clinical_post_id", null: false
    t.datetime "created_at", null: false
    t.string "image_ref", null: false
    t.string "image_type_code", null: false
    t.text "note"
    t.string "patient_hn", null: false
    t.datetime "updated_at", null: false
    t.string "visit_id", null: false
    t.index ["clinical_post_id"], name: "index_dental_clinical_image_records_on_clinical_post_id"
    t.index ["patient_hn", "captured_at"], name: "index_dental_image_records_on_patient_time"
  end

  create_table "dental_clinical_posts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "form_type", null: false
    t.string "patient_hn", null: false
    t.text "payload_json", default: "{}", null: false
    t.datetime "posted_at", null: false
    t.string "posted_by_id", null: false
    t.string "stage"
    t.datetime "updated_at", null: false
    t.string "visit_id", null: false
    t.text "void_reason"
    t.datetime "voided_at"
    t.index ["form_type"], name: "index_dental_clinical_posts_on_form_type"
    t.index ["patient_hn"], name: "index_dental_clinical_posts_on_patient_hn"
    t.index ["visit_id", "posted_at"], name: "index_dental_clinical_posts_on_visit_posted"
  end

  create_table "dental_clinical_procedure_records", force: :cascade do |t|
    t.integer "clinical_post_id", null: false
    t.datetime "created_at", null: false
    t.text "note"
    t.datetime "occurred_at", null: false
    t.string "patient_hn", null: false
    t.string "procedure_item_code", null: false
    t.decimal "quantity", precision: 6, scale: 2, default: "1.0", null: false
    t.text "surface_codes_json", default: "[]", null: false
    t.string "tooth_code"
    t.datetime "updated_at", null: false
    t.string "visit_id", null: false
    t.index ["clinical_post_id"], name: "index_dental_clinical_procedure_records_on_clinical_post_id"
    t.index ["patient_hn", "occurred_at"], name: "index_dental_procedure_records_on_patient_time"
  end

  create_table "dental_image_type_references", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_dental_image_type_references_on_code", unique: true
  end

  create_table "dental_invoice_line_items", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.decimal "copay_amount", precision: 12, scale: 2
    t.decimal "copay_percent", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.integer "dental_invoice_id", null: false
    t.string "item_code", null: false
    t.string "item_name", null: false
    t.string "item_type", null: false
    t.string "price_source"
    t.decimal "quantity", precision: 10, scale: 2, null: false
    t.string "unit"
    t.decimal "unit_price", precision: 12, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["dental_invoice_id"], name: "index_dental_invoice_line_items_on_dental_invoice_id"
  end

  create_table "dental_invoices", force: :cascade do |t|
    t.string "actor_id"
    t.decimal "copay_amount", precision: 12, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.string "eligibility_code"
    t.string "external_invoice_ref"
    t.string "invoice_id", null: false
    t.datetime "paid_at"
    t.string "patient_name"
    t.string "payment_status", default: "pending", null: false
    t.datetime "sent_at"
    t.decimal "total_amount", precision: 12, scale: 2, default: "0.0"
    t.datetime "updated_at", null: false
    t.string "visit_id", null: false
    t.index ["invoice_id"], name: "index_dental_invoices_on_invoice_id", unique: true
    t.index ["payment_status"], name: "index_dental_invoices_on_payment_status"
    t.index ["visit_id"], name: "index_dental_invoices_on_visit_id"
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

  create_table "dental_payment_bridge_events", force: :cascade do |t|
    t.string "actor_id"
    t.datetime "created_at", null: false
    t.string "from_stage", null: false
    t.string "hook_type", null: false
    t.text "payload_json", default: "{}", null: false
    t.string "status", default: "pending", null: false
    t.string "to_stage", null: false
    t.datetime "updated_at", null: false
    t.string "visit_id", null: false
    t.index ["hook_type"], name: "index_dental_payment_bridge_events_on_hook_type"
    t.index ["status"], name: "index_dental_payment_bridge_events_on_status"
    t.index ["visit_id", "created_at"], name: "index_dental_payment_events_on_visit_created"
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

  create_table "dental_queue_entries", force: :cascade do |t|
    t.string "actor_id"
    t.datetime "created_at", null: false
    t.string "dentist"
    t.text "metadata_json", default: "{}", null: false
    t.string "mrn", null: false
    t.string "patient_name", null: false
    t.string "service", null: false
    t.string "source", null: false
    t.string "starts_at", null: false
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.string "visit_id", null: false
    t.index ["source"], name: "index_dental_queue_entries_on_source"
    t.index ["status"], name: "index_dental_queue_entries_on_status"
    t.index ["visit_id"], name: "index_dental_queue_entries_on_visit_id", unique: true
  end

  create_table "dental_requisition_line_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "dental_requisition_id", null: false
    t.string "item_code", null: false
    t.string "item_name", null: false
    t.string "item_type", null: false
    t.decimal "quantity", precision: 10, scale: 2, null: false
    t.string "unit", null: false
    t.datetime "updated_at", null: false
    t.index ["dental_requisition_id"], name: "index_dental_requisition_line_items_on_dental_requisition_id"
    t.index ["item_type", "item_code"], name: "index_dental_requisition_line_items_on_item_type_and_item_code"
  end

  create_table "dental_requisitions", force: :cascade do |t|
    t.datetime "approved_at"
    t.string "approver_id"
    t.string "cancel_reason"
    t.datetime "cancelled_at"
    t.string "canceller_id"
    t.datetime "created_at", null: false
    t.string "dispense_number"
    t.datetime "dispensed_at"
    t.string "dispenser_id"
    t.datetime "received_at"
    t.string "receiver_id"
    t.string "requester_id", null: false
    t.string "requisition_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.string "visit_id"
    t.index ["requester_id"], name: "index_dental_requisitions_on_requester_id"
    t.index ["requisition_id"], name: "index_dental_requisitions_on_requisition_id", unique: true
    t.index ["status"], name: "index_dental_requisitions_on_status"
    t.index ["visit_id"], name: "index_dental_requisitions_on_visit_id"
  end

  create_table "dental_stock_movements", force: :cascade do |t|
    t.string "actor_id"
    t.datetime "created_at", null: false
    t.string "direction", null: false
    t.string "item_code", null: false
    t.string "item_type", null: false
    t.string "movement_ref", null: false
    t.text "note"
    t.integer "quantity", null: false
    t.string "reference_id"
    t.string "reference_type"
    t.string "source", null: false
    t.string "unit", null: false
    t.datetime "updated_at", null: false
    t.index ["direction"], name: "index_dental_stock_movements_on_direction"
    t.index ["item_type", "item_code"], name: "index_dental_stock_movements_on_item_type_and_item_code"
    t.index ["movement_ref"], name: "index_dental_stock_movements_on_movement_ref", unique: true
    t.index ["reference_type", "reference_id", "direction"], name: "idx_stock_movements_idempotency", unique: true
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

  create_table "dental_usage_records", force: :cascade do |t|
    t.string "actor_id"
    t.string "clinical_post_id"
    t.datetime "created_at", null: false
    t.string "deduct_error"
    t.datetime "deducted_at"
    t.integer "deducted_quantity", default: 0
    t.datetime "failed_at"
    t.string "item_code", null: false
    t.string "item_name", null: false
    t.string "item_type", null: false
    t.string "movement_ref"
    t.integer "requested_quantity", default: 1, null: false
    t.string "status", default: "pending_deduct", null: false
    t.string "unit", null: false
    t.datetime "updated_at", null: false
    t.string "usage_id", null: false
    t.string "visit_id", null: false
    t.string "void_reason"
    t.datetime "voided_at"
    t.index ["clinical_post_id"], name: "index_dental_usage_records_on_clinical_post_id"
    t.index ["item_type", "item_code"], name: "index_dental_usage_records_on_item_type_and_item_code"
    t.index ["status"], name: "index_dental_usage_records_on_status"
    t.index ["usage_id"], name: "index_dental_usage_records_on_usage_id", unique: true
    t.index ["visit_id"], name: "index_dental_usage_records_on_visit_id"
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

  add_foreign_key "dental_clinical_chart_records", "dental_clinical_posts", column: "clinical_post_id"
  add_foreign_key "dental_clinical_image_records", "dental_clinical_posts", column: "clinical_post_id"
  add_foreign_key "dental_clinical_procedure_records", "dental_clinical_posts", column: "clinical_post_id"
  add_foreign_key "dental_invoice_line_items", "dental_invoices"
  add_foreign_key "dental_procedure_item_coverages", "dental_procedure_items", column: "procedure_item_id"
  add_foreign_key "dental_procedure_items", "dental_procedure_groups", column: "procedure_group_id"
  add_foreign_key "dental_requisition_line_items", "dental_requisitions"
  add_foreign_key "dental_supply_item_coverages", "dental_supply_items", column: "supply_item_id"
  add_foreign_key "dental_supply_items", "dental_supply_categories", column: "supply_category_id"
end
