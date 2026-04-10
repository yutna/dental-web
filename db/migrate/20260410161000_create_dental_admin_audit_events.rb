class CreateDentalAdminAuditEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :dental_admin_audit_events do |t|
      t.string :actor_id, null: false
      t.string :action, null: false
      t.string :resource_type, null: false
      t.integer :resource_id
      t.text :metadata_json, null: false, default: "{}"
      t.datetime :created_at, null: false
    end

    add_index :dental_admin_audit_events, :created_at
    add_index :dental_admin_audit_events, :actor_id
    add_index :dental_admin_audit_events, :action
    add_index :dental_admin_audit_events, [ :resource_type, :resource_id ], name: "index_dental_admin_audit_events_on_resource"
  end
end
