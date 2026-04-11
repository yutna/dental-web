class DentalInvoice < ApplicationRecord
  has_many :line_items, class_name: "DentalInvoiceLineItem", dependent: :destroy

  validates :invoice_id, presence: true, uniqueness: true
  validates :visit_id, presence: true
  validates :payment_status, presence: true, inclusion: { in: Dental::Enums::PaymentStatus.allowed_values }
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :copay_amount, numericality: { greater_than_or_equal_to: 0 }

  scope :pending, -> { where(payment_status: "pending") }
  scope :paid, -> { where(payment_status: "paid") }
  scope :for_visit, ->(visit_id) { where(visit_id: visit_id) }

  def pending?
    payment_status == "pending"
  end

  def paid?
    payment_status == "paid"
  end

  def mark_paid!(paid_at: Time.current)
    raise Dental::Errors::InvalidTransition.new(
      details: { invoice_id: invoice_id, current_status: payment_status, attempted: "paid" }
    ) unless pending?

    update!(payment_status: "paid", paid_at: paid_at)
  end

  def recalculate_totals!
    totals = line_items.reload.reduce({ amount: 0, copay: 0 }) do |acc, item|
      acc[:amount] += item.amount.to_f
      acc[:copay] += (item.copay_amount || 0).to_f
      acc
    end

    update!(
      total_amount: totals[:amount],
      copay_amount: totals[:copay]
    )
  end
end
