require "digest"
require "securerandom"

module Backend
  module Providers
    module Local
      class SessionProvider
        def sign_in(email:, password:)
          if email.blank? || password.blank?
            raise Errors::AuthenticationError, "Email and password are required"
          end

          email = email.strip.downcase
          Security::SessionSnapshot.new(
            access_token: SecureRandom.hex(24),
            refresh_token: SecureRandom.hex(24),
            principal: build_principal(email)
          )
        end

        def sign_out(_snapshot)
          true
        end

        private

        def build_principal(email)
          roles = email.include?("admin") ? [ "admin" ] : [ "clinician" ]
          permissions = [ "workspace:read" ]
          permissions << "admin:access" if roles.include?("admin")

          Security::Principal.new(
            id: "local-#{Digest::SHA256.hexdigest(email).first(12)}",
            email: email,
            display_name: email.split("@").first.to_s.tr(".", " ").titleize,
            roles: roles,
            permissions: permissions
          )
        end
      end
    end
  end
end
