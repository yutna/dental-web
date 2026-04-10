class CreateDentalCoveragesAndPricingFallback < ActiveRecord::Migration[8.1]
  def change
    create_table :dental_procedure_item_coverages do |t|
      t.references :procedure_item, null: false, foreign_key: { to_table: :dental_procedure_items }
      t.string :eligibility_code, null: false
      t.date :effective_from, null: false
      t.date :effective_to
      t.decimal :price_opd, precision: 10, scale: 2, null: false, default: 0
      t.decimal :price_ipd, precision: 10, scale: 2, null: false, default: 0
      t.decimal :copay_amount, precision: 10, scale: 2
      t.decimal :copay_percent, precision: 5, scale: 2
      t.boolean :active, null: false, default: true
      t.integer :lock_version, null: false, default: 0

      t.timestamps
    end

    add_index :dental_procedure_item_coverages,
              [ :procedure_item_id, :eligibility_code, :effective_from ],
              name: "index_dental_proc_item_coverages_on_item_eligibility_from"

    create_table :dental_supply_item_coverages do |t|
      t.references :supply_item, null: false, foreign_key: { to_table: :dental_supply_items }
      t.string :eligibility_code, null: false
      t.date :effective_from, null: false
      t.date :effective_to
      t.decimal :unit_price, precision: 10, scale: 2, null: false, default: 0
      t.decimal :copay_amount, precision: 10, scale: 2
      t.decimal :copay_percent, precision: 5, scale: 2
      t.boolean :active, null: false, default: true
      t.integer :lock_version, null: false, default: 0

      t.timestamps
    end

    add_index :dental_supply_item_coverages,
              [ :supply_item_id, :eligibility_code, :effective_from ],
              name: "index_dental_supply_item_coverages_on_item_eligibility_from"

    add_column :dental_supply_items, :unit_price, :decimal,
               precision: 10,
               scale: 2,
               null: false,
               default: 0
  end
end
