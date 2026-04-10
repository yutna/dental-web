class AddLockVersionToDentalProcedureItems < ActiveRecord::Migration[8.1]
  def change
    add_column :dental_procedure_items, :lock_version, :integer, null: false, default: 0
  end
end
