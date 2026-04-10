class DentalQueueEntry < ApplicationRecord
  SOURCES = %w[appointment_sync walk_in referral].freeze
  STATUSES = %w[scheduled in_progress ready waiting_payment completed cancelled].freeze

  validates :visit_id, :patient_name, :mrn, :service, :starts_at, :status, :source, presence: true
  validates :visit_id, uniqueness: true
  validates :source, inclusion: { in: SOURCES }
  validates :status, inclusion: { in: STATUSES }

  scope :ordered_dashboard, -> { order(created_at: :desc, id: :desc) }

  def metadata
    JSON.parse(metadata_json.presence || "{}")
  rescue JSON::ParserError
    {}
  end
end
