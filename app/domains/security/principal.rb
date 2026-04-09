module Security
  class Principal
    attr_reader :id, :email, :display_name, :roles, :permissions

    def self.guest
      new(
        id: nil,
        email: nil,
        display_name: "Guest",
        roles: [],
        permissions: []
      )
    end

    def self.from_h(payload)
      return guest if payload.blank?

      payload = payload.deep_stringify_keys
      new(
        id: payload["id"],
        email: payload["email"],
        display_name: payload["display_name"] || payload["displayName"] || payload["email"],
        roles: payload["roles"],
        permissions: payload["permissions"]
      )
    end

    def initialize(id:, email:, display_name:, roles:, permissions:)
      @id = id&.to_s
      @email = email&.to_s
      @display_name = display_name&.to_s || email&.to_s
      @roles = normalize_items(roles)
      @permissions = normalize_items(permissions)
    end

    def guest?
      id.blank?
    end

    def allowed?(permission)
      permissions.include?(permission.to_s)
    end

    def to_h
      {
        "id" => id,
        "email" => email,
        "display_name" => display_name,
        "roles" => roles,
        "permissions" => permissions
      }
    end

    private

    def normalize_items(items)
      Array(items).map(&:to_s).reject(&:blank?).uniq.sort
    end
  end
end
