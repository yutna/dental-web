class CreateClinicServices < ActiveRecord::Migration[8.1]
  def change
    create_table :clinic_services do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.integer :default_duration_minutes, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :clinic_services, :code, unique: true
  end
end
