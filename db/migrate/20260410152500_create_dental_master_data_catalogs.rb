class CreateDentalMasterDataCatalogs < ActiveRecord::Migration[8.1]
  def change
    create_table :dental_procedure_groups do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :dental_procedure_groups, :code, unique: true

    create_table :dental_procedure_items do |t|
      t.references :procedure_group, null: false, foreign_key: { to_table: :dental_procedure_groups }
      t.string :code, null: false
      t.string :name, null: false
      t.decimal :price_opd, precision: 10, scale: 2, null: false, default: 0
      t.decimal :price_ipd, precision: 10, scale: 2, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :dental_procedure_items, :code, unique: true

    create_table :dental_medication_profiles do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.string :category, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :dental_medication_profiles, :code, unique: true

    create_table :dental_supply_categories do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :dental_supply_categories, :code, unique: true

    create_table :dental_supply_items do |t|
      t.references :supply_category, null: false, foreign_key: { to_table: :dental_supply_categories }
      t.string :code, null: false
      t.string :name, null: false
      t.string :unit, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :dental_supply_items, :code, unique: true

    create_table :dental_tooth_references do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.integer :sort_order, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :dental_tooth_references, :code, unique: true

    create_table :dental_tooth_surface_references do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.integer :sort_order, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :dental_tooth_surface_references, :code, unique: true

    create_table :dental_tooth_root_references do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.integer :sort_order, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :dental_tooth_root_references, :code, unique: true

    create_table :dental_tooth_piece_references do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.integer :sort_order, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :dental_tooth_piece_references, :code, unique: true

    create_table :dental_image_type_references do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :dental_image_type_references, :code, unique: true
  end
end
