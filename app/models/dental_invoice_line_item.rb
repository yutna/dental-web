class DentalInvoiceLineItem < ApplicationRecord
  ITEM_TYPES = %w[procedure medication supply].freeze

  belongs_to :dental_invoice

  validates :item_type, presence: true, inclusion: { in: ITEM_TYPES }
  validates :item_code, presence: true
  validates :item_name, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
