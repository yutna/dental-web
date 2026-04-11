class CreateDentalInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :dental_invoices do |t|
      t.string :invoice_id, null: false
      t.string :visit_id, null: false
      t.string :patient_name
      t.string :eligibility_code
      t.decimal :total_amount, precision: 12, scale: 2, default: 0
      t.decimal :copay_amount, precision: 12, scale: 2, default: 0
      t.string :payment_status, null: false, default: "pending"
      t.string :external_invoice_ref
      t.datetime :sent_at
      t.datetime :paid_at
      t.string :actor_id
      t.timestamps
    end

    add_index :dental_invoices, :invoice_id, unique: true
    add_index :dental_invoices, :visit_id
    add_index :dental_invoices, :payment_status

    create_table :dental_invoice_line_items do |t|
      t.references :dental_invoice, null: false, foreign_key: true
      t.string :item_type, null: false
      t.string :item_code, null: false
      t.string :item_name, null: false
      t.decimal :quantity, null: false, precision: 10, scale: 2
      t.string :unit
      t.decimal :unit_price, null: false, precision: 12, scale: 2
      t.decimal :amount, null: false, precision: 12, scale: 2
      t.string :price_source
      t.decimal :copay_amount, precision: 12, scale: 2
      t.decimal :copay_percent, precision: 5, scale: 2
      t.timestamps
    end
  end
end
