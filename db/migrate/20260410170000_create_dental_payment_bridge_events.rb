class CreateDentalPaymentBridgeEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :dental_payment_bridge_events do |t|
      t.string :visit_id, null: false
      t.string :hook_type, null: false
      t.string :from_stage, null: false
      t.string :to_stage, null: false
      t.string :actor_id
      t.string :status, null: false, default: "pending"
      t.text :payload_json, null: false, default: "{}"

      t.timestamps
    end

    add_index :dental_payment_bridge_events, [ :visit_id, :created_at ], name: "index_dental_payment_events_on_visit_created"
    add_index :dental_payment_bridge_events, :hook_type
    add_index :dental_payment_bridge_events, :status
  end
end
