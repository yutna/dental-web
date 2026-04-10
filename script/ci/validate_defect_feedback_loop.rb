#!/usr/bin/env ruby
# frozen_string_literal: true

require "open3"

BUG_LABEL_PATTERN = /(bug|defect|regression)/i
FEEDBACK_PATH_PREFIXES = [
  ".github/instructions/",
  ".github/skills/",
  ".github/prompts/",
  ".github/ISSUE_TEMPLATE/"
].freeze
FEEDBACK_PATH_EXACT = [
  ".github/copilot-instructions.md",
  ".github/pull_request_template.md",
  "AGENTS.md",
  "README.md"
].freeze

def labels
  ENV.fetch("PR_LABELS", "").split(",").map(&:strip).reject(&:empty?)
end

def defect_pr?
  labels.any? { |label| label.match?(BUG_LABEL_PATTERN) }
end

def changed_files
  base_sha = ENV.fetch("BASE_SHA", "").strip
  head_sha = ENV.fetch("HEAD_SHA", "").strip

  if base_sha.empty? || head_sha.empty?
    abort "BASE_SHA and HEAD_SHA are required when validating defect feedback loop."
  end

  diff_range = "#{base_sha}...#{head_sha}"
  stdout, stderr, status = Open3.capture3("git", "diff", "--name-only", diff_range)
  unless status.success?
    abort "Failed to compute changed files for #{diff_range}: #{stderr}"
  end

  stdout.lines.map(&:strip).reject(&:empty?)
end

def feedback_file?(path)
  FEEDBACK_PATH_EXACT.include?(path) ||
    FEEDBACK_PATH_PREFIXES.any? { |prefix| path.start_with?(prefix) }
end

unless defect_pr?
  puts "Defect feedback loop gate skipped: no bug/defect/regression label on this PR."
  exit 0
end

paths = changed_files
feedback_paths = paths.select { |path| feedback_file?(path) }

if feedback_paths.any?
  puts "Defect feedback loop gate passed."
  puts "Feedback artifacts updated:"
  feedback_paths.each { |path| puts "- #{path}" }
  exit 0
end

puts "Defect feedback loop gate failed."
puts "Bug/defect/regression-labeled PRs must update at least one Copilot instruction artifact."
puts "Allowed update paths:"
(FEEDBACK_PATH_PREFIXES + FEEDBACK_PATH_EXACT).each { |path| puts "- #{path}" }
exit 1
