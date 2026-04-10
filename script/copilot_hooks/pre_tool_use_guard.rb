#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"

def parse_json(input)
  JSON.parse(input)
rescue JSON::ParserError
  {}
end

event = parse_json(STDIN.read.to_s)
tool_name = event["toolName"].to_s.downcase

shell_tools = %w[bash powershell shell execute]
exit 0 unless shell_tools.include?(tool_name)

raw_tool_args = event["toolArgs"]
tool_args = if raw_tool_args.is_a?(String)
  parsed = parse_json(raw_tool_args)
  parsed.is_a?(Hash) ? parsed : { "command" => raw_tool_args }
elsif raw_tool_args.is_a?(Hash)
  raw_tool_args
else
  {}
end

command = tool_args["command"].to_s
exit 0 if command.strip.empty?

rules = [
  [ /\bgit\s+reset\s+--hard\b/i, "Blocked destructive git history rewrite (git reset --hard)." ],
  [ /\bgit\s+checkout\s+--\b/i, "Blocked destructive checkout overwrite (git checkout --)." ],
  [ /\bgit\s+clean\s+-fdx?\b/i, "Blocked destructive untracked file removal (git clean -fd/-fdx)." ],
  [ /\brm\s+-rf\s+\/\b/i, "Blocked dangerous filesystem deletion (rm -rf /)." ],
  [ /\bmkfs(\.\w+)?\b/i, "Blocked disk formatting command (mkfs)." ],
  [ /\bdd\s+if=.*\bof=\/dev\//i, "Blocked raw device write command (dd ... of=/dev/*)." ],
  [ /\bpkill\b/i, "Blocked process-kill by pattern (pkill). Use explicit PID kill instead." ],
  [ /\bkillall\b/i, "Blocked process-kill by name (killall). Use explicit PID kill instead." ],
  [ /\bDROP\s+TABLE\b/i, "Blocked destructive SQL (DROP TABLE)." ],
  [ /\bTRUNCATE\s+TABLE\b/i, "Blocked destructive SQL (TRUNCATE TABLE)." ]
]

matched = rules.find { |pattern, _reason| command.match?(pattern) }
exit 0 unless matched

_pattern, reason = matched
puts({ permissionDecision: "deny", permissionDecisionReason: reason }.to_json)
