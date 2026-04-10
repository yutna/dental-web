class DentalAdminAuditEvent < ApplicationRecord
  validates :actor_id, presence: true
  validates :action, presence: true
  validates :resource_type, presence: true
  validates :metadata_json, presence: true

  before_update :prevent_mutation
  before_destroy :prevent_mutation

  scope :recent_first, -> { order(created_at: :desc, id: :desc) }

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
