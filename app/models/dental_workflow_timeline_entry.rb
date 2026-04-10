class DentalWorkflowTimelineEntry < ApplicationRecord
  validates :visit_id, presence: true
  validates :from_stage, presence: true
  validates :to_stage, presence: true
  validates :event_type, presence: true
  validates :metadata_json, presence: true

  before_update :prevent_mutation
  before_destroy :prevent_mutation

  scope :for_visit, ->(visit_id) { where(visit_id: visit_id).order(created_at: :asc, id: :asc) }

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
