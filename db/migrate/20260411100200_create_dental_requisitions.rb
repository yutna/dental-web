class CreateDentalRequisitions < ActiveRecord::Migration[8.1]
  def change
    create_table :dental_requisitions do |t|
      t.string :requisition_id, null: false
      t.string :visit_id
      t.string :requester_id, null: false
      t.string :approver_id
      t.string :dispenser_id
      t.string :receiver_id
      t.string :status, null: false, default: "pending"
      t.string :dispense_number
      t.string :cancel_reason
      t.datetime :approved_at
      t.datetime :dispensed_at
      t.datetime :received_at
      t.datetime :cancelled_at
      t.timestamps
    end

    add_index :dental_requisitions, :requisition_id, unique: true
    add_index :dental_requisitions, :visit_id
    add_index :dental_requisitions, :requester_id
    add_index :dental_requisitions, :status

    create_table :dental_requisition_line_items do |t|
      t.references :dental_requisition, null: false, foreign_key: true
      t.string :item_type, null: false
      t.string :item_code, null: false
      t.string :item_name, null: false
      t.decimal :quantity, null: false, precision: 10, scale: 2
      t.string :unit, null: false
      t.timestamps
    end

    add_index :dental_requisition_line_items, %i[item_type item_code]
  end
end
