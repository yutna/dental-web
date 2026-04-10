require "fileutils"
require "json"
require "securerandom"
require "time"

module Backend
  class ContractMismatchReporter
    def initialize(output_dir: Rails.configuration.x.bff.contract_diff_dir)
      @output_dir = output_dir
    end

    def write(local_snapshot:, remote_snapshot:)
      FileUtils.mkdir_p(output_dir)

      report_payload = {
        "generated_at" => Time.now.utc.iso8601,
        "canonical_contract" => "session_snapshot.v1",
        "differences" => differences(local_snapshot:, remote_snapshot:),
        "local_snapshot" => redacted_snapshot(local_snapshot),
        "remote_snapshot" => redacted_snapshot(remote_snapshot)
      }

      report_path = File.join(output_dir, report_filename)
      File.write(report_path, JSON.pretty_generate(report_payload))
      report_path
    end

    private

    attr_reader :output_dir

    def report_filename
      timestamp = Time.now.utc.strftime("%Y%m%dT%H%M%S")
      "session_contract_mismatch_#{timestamp}_#{SecureRandom.hex(4)}.json"
    end

    def differences(local_snapshot:, remote_snapshot:)
      local_principal = local_snapshot.principal
      remote_principal = remote_snapshot.principal

      [
        difference_for("principal.email", local_principal.email, remote_principal.email),
        difference_for("principal.roles", local_principal.roles, remote_principal.roles),
        difference_for("principal.permissions", local_principal.permissions, remote_principal.permissions)
      ].compact
    end

    def difference_for(field, local_value, remote_value)
      return if local_value == remote_value

      {
        "field" => field,
        "local" => local_value,
        "remote" => remote_value
      }
    end

    def redacted_snapshot(snapshot)
      {
        "access_token" => redact_token(snapshot.access_token),
        "refresh_token" => redact_token(snapshot.refresh_token),
        "principal" => snapshot.principal.to_h
      }
    end

    def redact_token(value)
      return nil if value.blank?

      "#{value.to_s.first(6)}...#{value.to_s.last(4)} (len=#{value.to_s.length})"
    end
  end
end
