class AddCancellerIdToDentalRequisitions < ActiveRecord::Migration[8.1]
  def change
    add_column :dental_requisitions, :canceller_id, :string
  end
end
