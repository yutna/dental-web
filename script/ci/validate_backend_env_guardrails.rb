#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname(__dir__).join("..", "..").expand_path
APPLICATION_FILE = ROOT.join("config", "application.rb")
INITIALIZER_FILE = ROOT.join("config", "initializers", "bff.rb")
ENV_EXAMPLE_FILE = ROOT.join(".env.example")

REQUIRED_KEYS = %w[
  BACKEND_API_BASE_URL
  BACKEND_API_OPEN_TIMEOUT
  BACKEND_API_READ_TIMEOUT
].freeze


def fail_with(message)
  warn("[backend-env-guardrails] #{message}")
  exit(1)
end


def read!(path)
  path.read
rescue Errno::ENOENT
  fail_with("Missing file: #{path}")
end

application = read!(APPLICATION_FILE)
initializer = read!(INITIALIZER_FILE)
env_example = read!(ENV_EXAMPLE_FILE)

REQUIRED_KEYS.each do |key|
  if application.match?(/ENV\.fetch\(\"#{Regexp.escape(key)}\"\s*,/)
    fail_with("#{APPLICATION_FILE} must not define defaults via ENV.fetch for #{key}")
  end

  unless application.include?("ENV[\"#{key}\"]")
    fail_with("#{APPLICATION_FILE} must read #{key} directly from ENV")
  end

  unless initializer.include?(key)
    fail_with("#{INITIALIZER_FILE} must validate required key #{key}")
  end

  env_line = env_example.lines.find { |line| line.start_with?("#{key}=") }
  if env_line.nil?
    fail_with("#{ENV_EXAMPLE_FILE} is missing #{key}=...")
  end

  value = env_line.split("=", 2).last.to_s.strip
  fail_with("#{ENV_EXAMPLE_FILE} has empty value for #{key}") if value.empty?
end

puts "[backend-env-guardrails] OK"
