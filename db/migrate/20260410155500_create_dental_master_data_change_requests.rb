class CreateDentalMasterDataChangeRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :dental_master_data_change_requests do |t|
      t.string :resource_type, null: false
      t.integer :resource_id, null: false
      t.string :change_type, null: false
      t.text :payload_json, null: false
      t.string :status, null: false, default: "pending"
      t.string :requested_by_id, null: false
      t.string :approved_by_id
      t.datetime :approved_at

      t.timestamps
    end

    add_index :dental_master_data_change_requests, [ :resource_type, :resource_id ], name: "index_dental_md_change_requests_on_resource"
    add_index :dental_master_data_change_requests, :status
  end
end
