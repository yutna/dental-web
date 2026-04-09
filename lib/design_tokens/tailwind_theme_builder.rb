require "json"
require "pathname"
require "set"

module DesignTokens
  class TailwindThemeBuilder
    REFERENCE_PATTERN = /\A\{(.+)\}\z/.freeze

    CATEGORY_PREFIX = {
      "brand-colors" => "brand",
      "background" => "bg",
      "text" => "text",
      "icon" => "icon",
      "border" => "border"
    }.freeze

    LIGHT_THEME_ALIASES = {
      "--color-app-surface-primary" => "--color-bg-neutral-primary",
      "--color-app-surface-secondary" => "--color-bg-neutral-secondary",
      "--color-app-surface-tertiary" => "--color-bg-neutral-tertiary",
      "--color-app-surface-disabled" => "--color-bg-neutral-disabled",
      "--color-app-text-primary" => "--color-text-neutral-primary",
      "--color-app-text-secondary" => "--color-text-neutral-secondary",
      "--color-app-text-tertiary" => "--color-text-neutral-tertiary",
      "--color-app-text-disabled" => "--color-text-neutral-disabled",
      "--color-app-icon-primary" => "--color-icon-neutral-primary",
      "--color-app-icon-secondary" => "--color-icon-neutral-secondary",
      "--color-app-icon-tertiary" => "--color-icon-neutral-tertiary",
      "--color-app-border-primary" => "--color-border-neutral-primary",
      "--color-app-border-secondary" => "--color-border-neutral-secondary",
      "--color-app-brand-primary" => "--color-brand-primary",
      "--color-app-brand-active" => "--color-brand-active",
      "--color-app-brand-secondary" => "--color-brand-secondary",
      "--color-app-brand-inverse" => "--color-brand-inverse"
    }.freeze

    DARK_THEME_OVERRIDES = {
      "--color-app-surface-primary" => "--color-bg-neutral-inverse-primary",
      "--color-app-surface-secondary" => "--color-bg-neutral-inverse-secondary",
      "--color-app-surface-tertiary" => "--color-bg-neutral-inverse-tertiary",
      "--color-app-surface-disabled" => "--color-bg-neutral-inverse-secondary",
      "--color-app-text-primary" => "--color-text-neutral-inverse-primary",
      "--color-app-text-secondary" => "--color-text-neutral-inverse-secondary",
      "--color-app-text-tertiary" => "--color-text-neutral-inverse-tertiary",
      "--color-app-text-disabled" => "--color-text-neutral-inverse-tertiary",
      "--color-app-icon-primary" => "--color-icon-neutral-inverse-primary",
      "--color-app-icon-secondary" => "--color-icon-neutral-inverse-secondary",
      "--color-app-icon-tertiary" => "--color-icon-neutral-inverse-tertiary",
      "--color-app-border-primary" => "--color-border-neutral-inverse-primary",
      "--color-app-border-secondary" => "--color-border-neutral-inverse-secondary",
      "--color-app-brand-inverse" => "--color-text-neutral-inverse-primary",
      "--color-bg-brand-default" => "--color-neutral-900",
      "--color-bg-brand-primary" => "--color-violet-900",
      "--color-bg-brand-secondary" => "--color-violet-800",
      "--color-bg-brand-tertiary" => "--color-violet-700",
      "--color-border-brand-primary" => "--color-indigo-700",
      "--color-border-brand-secondary" => "--color-violet-700"
    }.freeze

    def initialize(source_path:, output_path:)
      @source_path = Pathname(source_path)
      @output_path = Pathname(output_path)
    end

    def build!
      payload = JSON.parse(@source_path.read)
      primitive_tokens = flatten_tokens(payload.fetch("Primitive"))
      semantic_tokens = flatten_tokens(payload.fetch("Semantic"))

      primitive_vars = build_primitive_variables(primitive_tokens)
      semantic_vars = build_semantic_variables(semantic_tokens, primitive_vars)
      alias_vars = build_alias_variables(primitive_vars.values + semantic_vars.values)

      @output_path.dirname.mkpath
      @output_path.write(render_css(primitive_vars, semantic_vars, alias_vars))
    end

    private

    def flatten_tokens(node, path = [], acc = {})
      unless node.is_a?(Hash)
        acc[path] = node
        return acc
      end

      node.each do |key, value|
        flatten_tokens(value, path + [ key ], acc)
      end

      acc
    end

    def build_primitive_variables(tokens)
      vars = {}

      tokens.each do |path, value|
        normalized_path = normalize_path(path)
        ref_key = normalized_path.join(".")
        var_name = "--color-#{normalized_path.join("-")}"

        raise "Duplicate primitive token path: #{ref_key}" if vars.key?(ref_key)

        vars[ref_key] = ThemeVariable.new(var_name, normalize_color(value))
      end

      vars
    end

    def build_semantic_variables(tokens, primitive_vars)
      vars = {}

      tokens.each do |path, value|
        normalized_path = normalize_path(path)
        category = normalized_path.first
        semantic_path = normalized_path.drop(1)
        prefix = CATEGORY_PREFIX.fetch(category, category)
        var_name = "--color-#{([ prefix ] + semantic_path).join("-")}"

        raise "Duplicate semantic variable name: #{var_name}" if vars.key?(var_name)

        vars[var_name] = ThemeVariable.new(var_name, resolve_value(value, primitive_vars))
      end

      vars
    end

    def build_alias_variables(theme_variables)
      available = theme_variables.map(&:name).to_set
      aliases = {}

      LIGHT_THEME_ALIASES.each do |alias_name, target_name|
        raise "Unknown light alias target: #{target_name}" unless available.include?(target_name)

        aliases[alias_name] = ThemeVariable.new(alias_name, "var(#{target_name})")
      end

      overrideable = available + aliases.keys.to_set

      DARK_THEME_OVERRIDES.each do |alias_name, target_name|
        raise "Unknown dark override token: #{alias_name}" unless overrideable.include?(alias_name)
        raise "Unknown dark alias target: #{target_name}" unless available.include?(target_name)
      end

      aliases
    end

    def resolve_value(value, primitive_vars)
      value = value.to_s
      ref_match = value.match(REFERENCE_PATTERN)

      return normalize_color(value) unless ref_match

      ref_path = normalize_path(ref_match[1].split(".")).join(".")
      primitive_var = primitive_vars[ref_path]
      raise "Unresolved token reference: #{value}" if primitive_var.nil?

      "var(#{primitive_var.name})"
    end

    def normalize_path(path)
      path.map { |segment| normalize_segment(segment) }
    end

    def normalize_segment(segment)
      segment.to_s.strip.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "")
    end

    def normalize_color(value)
      value = value.to_s.strip
      return value if value.match?(/\A#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6})\z/)

      raise "Unsupported color value: #{value.inspect}"
    end

    def render_css(primitive_vars, semantic_vars, alias_vars)
      lines = []
      lines << "/*"
      lines << " * This file is generated by `bin/rails design_tokens:build`."
      lines << " * Source: config/design_tokens/brand_tokens.json"
      lines << " */"
      lines << ""
      lines << "@theme {"

      primitive_vars
        .values
        .sort_by(&:name)
        .each { |token| lines << "  #{token.name}: #{token.value};" }

      semantic_vars
        .values
        .sort_by(&:name)
        .each { |token| lines << "  #{token.name}: #{token.value};" }

      alias_vars
        .values
        .sort_by(&:name)
        .each { |token| lines << "  #{token.name}: #{token.value};" }

      lines << "}"
      lines << ""
      lines << ".dark {"

      DARK_THEME_OVERRIDES
        .sort_by { |name, _| name }
        .each do |alias_name, target_name|
          lines << "  #{alias_name}: var(#{target_name});"
        end

      lines << "}"
      lines << ""
      lines.join("\n")
    end

    ThemeVariable = Struct.new(:name, :value)
  end
end
