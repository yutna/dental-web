class CreateDentalQueueEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :dental_queue_entries do |t|
      t.string :visit_id, null: false
      t.string :patient_name, null: false
      t.string :mrn, null: false
      t.string :service, null: false
      t.string :dentist
      t.string :starts_at, null: false
      t.string :status, null: false
      t.string :source, null: false
      t.string :actor_id
      t.text :metadata_json, null: false, default: "{}"

      t.timestamps
    end

    add_index :dental_queue_entries, :visit_id, unique: true
    add_index :dental_queue_entries, :source
    add_index :dental_queue_entries, :status
  end
end
