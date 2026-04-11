class AddEventTypeToDentalAdminAuditEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :dental_admin_audit_events, :event_type, :string, default: "admin"
    add_index :dental_admin_audit_events, :event_type
  end
end
