class CreateDentalClinicalPostsAndProjections < ActiveRecord::Migration[8.1]
  def change
    create_table :dental_clinical_posts do |t|
      t.string :visit_id, null: false
      t.string :patient_hn, null: false
      t.string :form_type, null: false
      t.string :stage
      t.string :posted_by_id, null: false
      t.text :payload_json, null: false, default: "{}"
      t.datetime :posted_at, null: false
      t.datetime :voided_at
      t.text :void_reason
      t.timestamps
    end

    add_index :dental_clinical_posts, [ :visit_id, :posted_at ], name: "index_dental_clinical_posts_on_visit_posted"
    add_index :dental_clinical_posts, :patient_hn
    add_index :dental_clinical_posts, :form_type

    create_table :dental_clinical_chart_records do |t|
      t.references :clinical_post, null: false, foreign_key: { to_table: :dental_clinical_posts }
      t.string :visit_id, null: false
      t.string :patient_hn, null: false
      t.string :tooth_code, null: false
      t.text :surface_codes_json, null: false, default: "[]"
      t.text :root_codes_json, null: false, default: "[]"
      t.text :piece_codes_json, null: false, default: "[]"
      t.string :charting_code, null: false
      t.text :note
      t.datetime :occurred_at, null: false
      t.timestamps
    end

    add_index :dental_clinical_chart_records, [ :patient_hn, :tooth_code, :occurred_at ], name: "index_dental_chart_records_on_patient_tooth_time"

    create_table :dental_clinical_procedure_records do |t|
      t.references :clinical_post, null: false, foreign_key: { to_table: :dental_clinical_posts }
      t.string :visit_id, null: false
      t.string :patient_hn, null: false
      t.string :procedure_item_code, null: false
      t.string :tooth_code
      t.text :surface_codes_json, null: false, default: "[]"
      t.decimal :quantity, precision: 6, scale: 2, null: false, default: "1.0"
      t.text :note
      t.datetime :occurred_at, null: false
      t.timestamps
    end

    add_index :dental_clinical_procedure_records, [ :patient_hn, :occurred_at ], name: "index_dental_procedure_records_on_patient_time"

    create_table :dental_clinical_image_records do |t|
      t.references :clinical_post, null: false, foreign_key: { to_table: :dental_clinical_posts }
      t.string :visit_id, null: false
      t.string :patient_hn, null: false
      t.string :image_type_code, null: false
      t.string :image_ref, null: false
      t.text :note
      t.datetime :captured_at, null: false
      t.timestamps
    end

    add_index :dental_clinical_image_records, [ :patient_hn, :captured_at ], name: "index_dental_image_records_on_patient_time"
  end
end
