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

ActiveRecord::Schema[8.1].define(version: 2026_04_10_152500) do
  create_table "clinic_services", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.integer "default_duration_minutes", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_clinic_services_on_code", unique: true
  end

  create_table "dental_image_type_references", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_dental_image_type_references_on_code", unique: true
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

  create_table "dental_procedure_items", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
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

  create_table "dental_supply_items", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "supply_category_id", null: false
    t.string "unit", null: false
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

  add_foreign_key "dental_procedure_items", "dental_procedure_groups", column: "procedure_group_id"
  add_foreign_key "dental_supply_items", "dental_supply_categories", column: "supply_category_id"
end
