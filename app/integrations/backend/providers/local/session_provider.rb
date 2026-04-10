require "digest"
require "securerandom"

module Backend
  module Providers
    module Local
      class SessionProvider
        def sign_in(username:, password:)
          unless Rails.env.test?
            raise Errors::ServiceUnavailableError, "Local auth is disabled outside test. Configure BACKEND_API_BASE_URL for backend authentication."
          end

          if username.blank? || password.blank?
            raise Errors::AuthenticationError, "Username and password are required"
          end

          unless valid_demo_credentials?(username, password)
            raise Errors::AuthenticationError, "Invalid credentials"
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
        def valid_demo_credentials?(username, password)
          # Demo accounts: clinician.test / secret, admin.test / secret
          # Test accounts: admin@example.com / secret, clinician@example.com / secret
          password == "secret" && (
            username == "clinician.test" ||
            username == "admin.test" ||
            username == "admin@example.com" ||
            username == "clinician@example.com"
          )
        end
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
