class DentalStockMovement < ApplicationRecord
  ITEM_TYPES = %w[medication supply].freeze
  REFERENCE_TYPES = %w[usage requisition adjustment].freeze

  validates :movement_ref, presence: true, uniqueness: true
  validates :item_type, presence: true, inclusion: { in: ITEM_TYPES }
  validates :item_code, presence: true
  validates :direction, presence: true, inclusion: { in: Dental::Enums::StockDirection.allowed_values }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit, presence: true
  validates :source, presence: true, inclusion: { in: Dental::Enums::StockSource.allowed_values }
  validates :reference_type, inclusion: { in: REFERENCE_TYPES }, allow_blank: true

  scope :outbound, -> { where(direction: "out") }
  scope :inbound, -> { where(direction: "in") }
  scope :for_item, ->(item_type, item_code) { where(item_type: item_type, item_code: item_code) }

  def out?
    direction == "out"
  end

  def in?
    direction == "in"
  end
end
