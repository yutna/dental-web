module Dental::VisitsHelper
  STAGE_CLASSES = {
    "registered" => "border-app-border-primary bg-app-surface-secondary text-app-text-secondary",
    "checked-in" => "border-border-semantic-info-primary bg-bg-semantic-info-default text-text-semantic-info-primary",
    "screening" => "border-border-semantic-info-primary bg-bg-semantic-info-default text-text-semantic-info-primary",
    "ready-for-treatment" => "border-border-semantic-success-primary bg-bg-semantic-success-default text-text-semantic-success-primary",
    "in-treatment" => "border-border-semantic-warning-primary bg-bg-semantic-warning-default text-text-semantic-warning-primary",
    "waiting-payment" => "border-border-semantic-warning-primary bg-bg-semantic-warning-default text-text-semantic-warning-primary",
    "completed" => "border-border-semantic-success-primary bg-bg-semantic-success-default text-text-semantic-success-primary",
    "referred-out" => "border-app-border-primary bg-app-surface-secondary text-app-text-secondary",
    "cancelled" => "border-border-semantic-error-primary bg-bg-semantic-error-default text-text-semantic-error-primary"
  }.freeze

  TRANSITION_BUTTON_CLASSES = {
    "checked-in" => "bg-app-brand-primary text-app-brand-inverse hover:bg-app-brand-active",
    "screening" => "bg-app-brand-primary text-app-brand-inverse hover:bg-app-brand-active",
    "ready-for-treatment" => "bg-app-brand-primary text-app-brand-inverse hover:bg-app-brand-active",
    "in-treatment" => "bg-app-brand-primary text-app-brand-inverse hover:bg-app-brand-active",
    "waiting-payment" => "border border-border-semantic-warning-primary bg-bg-semantic-warning-default text-text-semantic-warning-primary hover:bg-app-surface-secondary",
    "completed" => "border border-border-semantic-success-primary bg-bg-semantic-success-default text-text-semantic-success-primary hover:bg-app-surface-secondary",
    "referred-out" => "border border-app-border-primary bg-app-surface-secondary text-app-text-primary hover:bg-app-surface-primary",
    "cancelled" => "border border-border-semantic-error-primary bg-bg-semantic-error-default text-text-semantic-error-primary hover:bg-app-surface-secondary"
  }.freeze

  def visit_stage_classes(stage)
    STAGE_CLASSES.fetch(stage.to_s, STAGE_CLASSES["registered"])
  end

  def visit_transition_button_classes(target_stage)
    TRANSITION_BUTTON_CLASSES.fetch(target_stage.to_s, "border border-app-border-primary bg-app-surface-secondary text-app-text-primary")
  end

  def queue_row_action(stage)
    case stage.to_s
    when "registered" then { label: "dental.queue_actions.check_in", transition: "checked-in" }
    when "checked-in" then { label: "dental.queue_actions.start_screening", transition: "screening" }
    when "screening" then { label: "dental.queue_actions.ready_treatment", transition: "ready-for-treatment" }
    when "ready-for-treatment" then { label: "dental.queue_actions.start_treatment", transition: "in-treatment" }
    when "in-treatment" then { label: "dental.queue_actions.send_cashier", transition: "waiting-payment" }
    when "waiting-payment" then { label: "dental.queue_actions.sync_payment", transition: nil }
    end
  end
end
