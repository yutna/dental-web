class CreateDentalWorkflowTimelineEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :dental_workflow_timeline_entries do |t|
      t.string :visit_id, null: false
      t.string :from_stage, null: false
      t.string :to_stage, null: false
      t.string :event_type, null: false
      t.string :actor_id
      t.text :metadata_json, null: false, default: "{}"
      t.datetime :created_at, null: false
    end

    add_index :dental_workflow_timeline_entries, [ :visit_id, :created_at ], name: "index_dental_workflow_timeline_on_visit_created"
    add_index :dental_workflow_timeline_entries, :event_type
  end
end
