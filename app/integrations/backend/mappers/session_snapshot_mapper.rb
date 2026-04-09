module Backend
  module Mappers
    class SessionSnapshotMapper
      class << self
        def from_remote(payload)
          payload = payload.to_h.deep_stringify_keys
          user_payload = payload["user"].presence || payload["principal"].presence || {}

          access_token = payload["access_token"] || payload["accessToken"] || payload["token"]
          refresh_token = payload["refresh_token"] || payload["refreshToken"]
          email = user_payload["email"]

          if access_token.blank? || email.blank?
            raise Errors::UnexpectedResponseError, "Remote auth payload is missing required canonical fields"
          end

          principal = Security::Principal.new(
            id: user_payload["id"] || user_payload["user_id"] || user_payload["uid"] || email,
            email: email,
            display_name: user_payload["display_name"] || user_payload["displayName"] || email,
            roles: user_payload["roles"],
            permissions: payload["permissions"] || user_payload["permissions"] || []
          )

          Security::SessionSnapshot.new(
            access_token: access_token,
            refresh_token: refresh_token,
            principal: principal
          )
        end
      end
    end
  end
end
