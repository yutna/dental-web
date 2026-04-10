#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "pathname"
require "yaml"

class CopilotAssetsValidator
  FRONTMATTER_RULES = {
    ".github/instructions/*.instructions.md" => {
      "applyTo" => String
    },
    ".github/agents/*.agent.md" => {
      "name" => String,
      "description" => String,
      "tools" => Array
    },
    ".github/skills/*/SKILL.md" => {
      "name" => String,
      "description" => String
    },
    ".github/prompts/*.prompt.md" => {
      "name" => String,
      "description" => String
    }
  }.freeze

  def initialize(root: Pathname.new(__dir__).join("../..").expand_path)
    @root = root
    @errors = []
  end

  def call
    validate_markdown_frontmatter
    validate_hooks_json
    validate_named_assets_uniqueness(".github/agents/*.agent.md", "agent")
    validate_named_assets_uniqueness(".github/skills/*/SKILL.md", "skill")
    validate_named_assets_uniqueness(".github/prompts/*.prompt.md", "prompt")
    report!
  end

  private

  attr_reader :root, :errors

  def validate_markdown_frontmatter
    FRONTMATTER_RULES.each do |pattern, required_keys|
      files = root.glob(pattern).sort
      if files.empty?
        errors << "No files matched required pattern: #{pattern}"
        next
      end

      files.each do |path|
        metadata = parse_frontmatter(path)
        next unless metadata

        required_keys.each do |key, expected_type|
          value = metadata[key]
          if value.nil?
            errors << "#{relative(path)} is missing frontmatter key: #{key}"
            next
          end

          unless value.is_a?(expected_type)
            errors << "#{relative(path)} frontmatter key #{key} must be #{expected_type}, got #{value.class}"
            next
          end

          if value.is_a?(String) && value.strip.empty?
            errors << "#{relative(path)} frontmatter key #{key} cannot be blank"
          elsif value.is_a?(Array) && value.empty?
            errors << "#{relative(path)} frontmatter key #{key} cannot be empty"
          end
        end

        tools = metadata["tools"]
        next unless tools

        unless tools.all? { |tool| tool.is_a?(String) && !tool.strip.empty? }
          errors << "#{relative(path)} frontmatter key tools must contain only non-empty strings"
        end
      end
    end
  end

  def validate_hooks_json
    hook_files = root.glob(".github/hooks/*.json").sort
    if hook_files.empty?
      errors << "No hook files found under .github/hooks/*.json"
      return
    end

    hook_files.each do |path|
      payload = parse_json(path)
      next unless payload

      version = payload["version"]
      unless version.is_a?(Integer) && version.positive?
        errors << "#{relative(path)} must set an integer version >= 1"
      end

      hooks = payload["hooks"]
      unless hooks.is_a?(Hash)
        errors << "#{relative(path)} must contain a hooks object"
        next
      end

      pre_tool_use = hooks["preToolUse"]
      unless pre_tool_use.is_a?(Array) && pre_tool_use.any?
        errors << "#{relative(path)} must define hooks.preToolUse as a non-empty array"
        next
      end

      pre_tool_use.each_with_index do |entry, index|
        unless entry.is_a?(Hash)
          errors << "#{relative(path)} hooks.preToolUse[#{index}] must be an object"
          next
        end

        unless entry["type"] == "command"
          errors << "#{relative(path)} hooks.preToolUse[#{index}] type must be command"
        end

        bash_command = entry["bash"]
        powershell_command = entry["powershell"]
        if blank_string?(bash_command) && blank_string?(powershell_command)
          errors << "#{relative(path)} hooks.preToolUse[#{index}] must define bash or powershell command"
        end
      end
    end
  end

  def validate_named_assets_uniqueness(pattern, label)
    names = Hash.new { |hash, key| hash[key] = [] }

    root.glob(pattern).sort.each do |path|
      metadata = parse_frontmatter(path)
      next unless metadata

      name = metadata["name"]
      next if name.nil? || blank_string?(name)

      names[name.strip] << relative(path)
    end

    names.each do |name, locations|
      next if locations.size == 1

      errors << "Duplicate #{label} name '#{name}' in: #{locations.join(', ')}"
    end
  end

  def parse_json(path)
    JSON.parse(path.read)
  rescue JSON::ParserError => e
    errors << "#{relative(path)} is not valid JSON: #{e.message}"
    nil
  end

  def parse_frontmatter(path)
    content = path.read
    match = content.match(/\A---\s*\n(?<yaml>.*?)\n---\s*(?:\n|\z)/m)
    unless match
      errors << "#{relative(path)} is missing YAML frontmatter block"
      return nil
    end

    metadata = YAML.safe_load(match[:yaml], permitted_classes: [], permitted_symbols: [], aliases: false)
    unless metadata.is_a?(Hash)
      errors << "#{relative(path)} frontmatter must evaluate to a YAML map/object"
      return nil
    end

    metadata
  rescue Psych::SyntaxError => e
    errors << "#{relative(path)} contains invalid YAML frontmatter: #{e.message}"
    nil
  end

  def blank_string?(value)
    !value.is_a?(String) || value.strip.empty?
  end

  def relative(path)
    path.relative_path_from(root).to_s
  end

  def report!
    if errors.empty?
      puts "Copilot customization assets are valid."
      return
    end

    puts "Copilot customization asset validation failed:"
    errors.each { |message| puts "- #{message}" }
    exit 1
  end
end

CopilotAssetsValidator.new.call
