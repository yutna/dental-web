class CreateDentalStockMovements < ActiveRecord::Migration[8.1]
  def change
    create_table :dental_stock_movements do |t|
      t.string :movement_ref, null: false
      t.string :item_type, null: false # "medication" | "supply"
      t.string :item_code, null: false
      t.string :direction, null: false # "in" | "out"
      t.integer :quantity, null: false
      t.string :unit, null: false
      t.string :source, null: false # "pharmacy" | "requisition" | "adjustment"
      t.string :reference_type # "usage" | "requisition" | "adjustment"
      t.string :reference_id
      t.string :actor_id
      t.text :note
      t.timestamps
    end

    add_index :dental_stock_movements, :movement_ref, unique: true
    add_index :dental_stock_movements, [ :reference_type, :reference_id, :direction ],
              unique: true, name: "idx_stock_movements_idempotency"
    add_index :dental_stock_movements, [ :item_type, :item_code ]
    add_index :dental_stock_movements, :direction
  end
end
