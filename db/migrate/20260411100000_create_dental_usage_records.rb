class CreateDentalUsageRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :dental_usage_records do |t|
      t.string :usage_id, null: false
      t.string :visit_id, null: false
      t.string :clinical_post_id
      t.string :item_type, null: false # "medication" | "supply"
      t.string :item_code, null: false
      t.string :item_name, null: false
      t.integer :requested_quantity, null: false, default: 1
      t.integer :deducted_quantity, default: 0
      t.string :unit, null: false
      t.string :status, null: false, default: "pending_deduct"
      t.string :deduct_error
      t.string :movement_ref
      t.string :actor_id
      t.datetime :deducted_at
      t.datetime :failed_at
      t.datetime :voided_at
      t.string :void_reason
      t.timestamps
    end

    add_index :dental_usage_records, :usage_id, unique: true
    add_index :dental_usage_records, :visit_id
    add_index :dental_usage_records, :clinical_post_id
    add_index :dental_usage_records, :status
    add_index :dental_usage_records, [ :item_type, :item_code ]
  end
end
