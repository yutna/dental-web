require Rails.root.join("lib/design_tokens/tailwind_theme_builder")

namespace :design_tokens do
  desc "Generate Tailwind theme variables from design token source"
  task build: :environment do
    source_path = Rails.root.join("config/design_tokens/brand_tokens.json")
    output_path = Rails.root.join("app/assets/tailwind/tokens.generated.css")

    DesignTokens::TailwindThemeBuilder
      .new(source_path:, output_path:)
      .build!

    puts "Generated #{output_path.relative_path_from(Rails.root)} from #{source_path.relative_path_from(Rails.root)}"
  end
end
