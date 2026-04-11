module Dental::StatusHelper
  PAYMENT_BADGE_CLASSES = {
    "pending"  => "border-border-semantic-warning-primary bg-bg-semantic-warning-default text-text-semantic-warning-primary",
    "partial"  => "border-border-semantic-info-primary bg-bg-semantic-info-default text-text-semantic-info-primary",
    "paid"     => "border-border-semantic-success-primary bg-bg-semantic-success-default text-text-semantic-success-primary",
    "voided"   => "border-border-semantic-error-primary bg-bg-semantic-error-default text-text-semantic-error-primary",
    "refunded" => "border-app-border-primary bg-app-surface-secondary text-app-text-secondary"
  }.freeze

  def stage_badge(stage, label: nil)
    label ||= t("dental.enums.visit_stage.#{stage}", default: stage.to_s.titleize)
    render "components/status_badge", label:, status: stage.to_s
  end

  def payment_badge(status, label: nil)
    label ||= status.to_s.titleize
    css = PAYMENT_BADGE_CLASSES.fetch(status.to_s, PAYMENT_BADGE_CLASSES["pending"])
    tag.span(label, class: "inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold #{css}")
  end
end
