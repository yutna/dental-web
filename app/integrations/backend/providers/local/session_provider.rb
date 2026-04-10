require "digest"
require "securerandom"

module Backend
  module Providers
    module Local
      class SessionProvider
        def sign_in(username:, password:)
          if username.blank? || password.blank?
            raise Errors::AuthenticationError, "Username and password are required"
          end

          username = username.strip
          Security::SessionSnapshot.new(
            access_token:  SecureRandom.hex(24),
            refresh_token: SecureRandom.hex(24),
            csrf_token:    SecureRandom.hex(32),
            principal:     build_principal(username)
          )
        end

        def sign_out(_snapshot)
          true
        end

        def refresh(snapshot)
          return snapshot if snapshot.guest?

          Security::SessionSnapshot.new(
            access_token:  SecureRandom.hex(24),
            refresh_token: SecureRandom.hex(24),
            csrf_token:    SecureRandom.hex(32),
            principal:     snapshot.principal
          )
        end

        private

        def build_principal(username)
          roles       = username.include?("admin") ? [ "admin" ] : [ "clinician" ]
          permissions = [ "workspace:read" ]
          permissions << "admin:access" if roles.include?("admin")

          Security::Principal.new(
            id:           "local-#{Digest::SHA256.hexdigest(username).first(12)}",
            username:     username,
            email:        nil,
            display_name: username.tr(".", " ").split.map(&:capitalize).join(" "),
            roles:        roles,
            permissions:  permissions
          )
        end
      end
    end
  end
end
