module ApplicationHelper
	def flash_toast_entries(flash_store)
		flash_store.to_hash.slice("notice", "alert").filter_map do |kind, message|
			next if message.blank?

			success = kind.to_s == "notice"
			{
				message:,
				role: success ? "status" : "alert",
				timeout: success ? 4500 : 7000,
				border_class: success ? "border-border-semantic-success-primary" : "border-border-semantic-error-primary",
				bg_class: success ? "bg-bg-semantic-success-default" : "bg-bg-semantic-error-default",
				text_class: success ? "text-text-semantic-success-primary" : "text-text-semantic-error-primary"
			}
		end
	end
end
