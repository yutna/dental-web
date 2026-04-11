module Backend
  module Mappers
    class SessionSnapshotMapper
      class << self
        # Build snapshot from a raw Bearer JWT (for API v1 endpoints).
        # Unlike from_remote, this doesn't expect refresh/csrf tokens —
        # it only decodes the access token to extract the principal.
        def from_bearer(access_token)
          return Security::SessionSnapshot.guest if access_token.blank?

          user_session = decode_jwt_payload(access_token)["user_session"].presence || {}
          email        = user_session["email"]

          return Security::SessionSnapshot.guest if email.blank?

          principal = Security::Principal.new(
            id:           user_session["id"],
            username:     user_session["username"],
            email:        email,
            display_name: build_display_name(user_session),
            roles:        Array(user_session["roles"]),
            permissions:  inject_bff_permissions(user_session)
          )

          Security::SessionSnapshot.new(
            access_token:  access_token,
            refresh_token: nil,
            csrf_token:    nil,
            principal:     principal
          )
        rescue StandardError => e
          Rails.logger.warn("[SessionSnapshotMapper] from_bearer failed: #{e.class} - #{e.message}")
          Security::SessionSnapshot.guest
        end

        def from_remote(payload)
          payload = payload.to_h.deep_stringify_keys

          access_token  = payload["access_token"]
          refresh_token = payload["refresh_token"]
          csrf_token    = payload["csrf_token"]

          if access_token.blank?
            raise Errors::UnexpectedResponseError, "Remote auth payload missing access_token"
          end

          user_session = decode_jwt_payload(access_token)["user_session"].presence || {}
          email        = user_session["email"]

          if email.blank?
            raise Errors::UnexpectedResponseError, "Remote auth JWT missing user_session.email"
          end

          principal = Security::Principal.new(
            id:           user_session["id"],
            username:     user_session["username"],
            email:        email,
            display_name: build_display_name(user_session),
            roles:        Array(user_session["roles"]),
            permissions:  inject_bff_permissions(user_session)
          )

          Security::SessionSnapshot.new(
            access_token:  access_token,
            refresh_token: refresh_token,
            csrf_token:    csrf_token,
            principal:     principal
          )
        end

        private

        def decode_jwt_payload(token)
          segments = token.to_s.split(".")
          return {} unless segments.length >= 2

          padding = "=" * ((4 - segments[1].length % 4) % 4)
          JSON.parse(Base64.urlsafe_decode64(segments[1] + padding))
        rescue JSON::ParserError, ArgumentError
          {}
        end

        def build_display_name(user_session)
          fullname = user_session["fullname"].presence
          return fullname if fullname

          [ user_session["first_name_thai"], user_session["last_name_thai"] ].compact.join(" ").presence ||
            [ user_session["first_name_eng"], user_session["last_name_eng"] ].compact.join(" ").presence ||
            user_session["username"] ||
            user_session["email"]
        end

        def inject_bff_permissions(user_session)
          permissions = [ "workspace:read", "dental:read", "dental:workflow:read", "dental:workflow:write" ]
          api_roles   = Array(user_session["roles"]).map(&:to_s)

          if api_roles.include?("admin")
            permissions << "admin:access"
          end

          permissions
        end
      end
    end
  end
end
