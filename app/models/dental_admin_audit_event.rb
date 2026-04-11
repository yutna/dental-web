class DentalAdminAuditEvent < ApplicationRecord
  EVENT_TYPES = %w[workflow clinical stock requisition billing print admin].freeze

  validates :actor_id, presence: true
  validates :action, presence: true
  validates :resource_type, presence: true
  validates :metadata_json, presence: true
  validates :event_type, inclusion: { in: EVENT_TYPES }, allow_nil: true

  before_update :prevent_mutation
  before_destroy :prevent_mutation

  scope :recent_first, -> { order(created_at: :desc, id: :desc) }
  scope :by_event_type, ->(type) { where(event_type: type) if type.present? }

  def metadata
    JSON.parse(metadata_json)
  rescue JSON::ParserError
    {}
  end

  private

  def prevent_mutation
    errors.add(:base, "append_only")
    throw :abort
  end
end
