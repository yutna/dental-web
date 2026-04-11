class DentalRequisitionLineItem < ApplicationRecord
  ITEM_TYPES = %w[medication supply].freeze

  belongs_to :dental_requisition

  validates :item_type, presence: true, inclusion: { in: ITEM_TYPES }
  validates :item_code, presence: true
  validates :item_name, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit, presence: true
end
