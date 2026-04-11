require "rails_helper"

RSpec.describe "JWT claims-to-policy context binding" do
  let(:mapper) { Backend::Mappers::SessionSnapshotMapper }

  # Helper: build a fake JWT token encoding the given user_session payload
  def build_jwt(user_session)
    header  = Base64.urlsafe_encode64('{"alg":"none","typ":"JWT"}', padding: false)
    payload = Base64.urlsafe_encode64({ "user_session" => user_session }.to_json, padding: false)
    "#{header}.#{payload}.unsigned"
  end

  # -------------------------------------------------------------------------
  # Per-role mapping through from_bearer (full end-to-end JWT → Principal)
  # -------------------------------------------------------------------------
  describe "role→permission mapping via from_bearer" do
    Security::Principal::RECOGNIZED_DENTAL_ROLES.each do |role|
      context "with role #{role}" do
        let(:token) do
          build_jwt(
            "id" => "jwt-#{role}",
            "email" => "#{role}@clinic.com",
            "username" => role,
            "fullname" => role.tr("_", " ").capitalize,
            "roles" => [role]
          )
        end

        let(:snapshot) { mapper.from_bearer(token) }
        let(:principal) { snapshot.principal }

        it "produces a non-guest principal" do
          expect(principal.guest?).to be false
        end

        it "preserves the role in principal.roles" do
          expect(principal.roles).to include(role)
        end

        it "exposes the role in dental_roles" do
          expect(principal.dental_roles).to include(role)
        end

        it "always includes base permissions" do
          mapper::BASE_PERMISSIONS.each do |perm|
            expect(principal.allowed?(perm)).to be(true),
              "#{role} should always have base permission #{perm}"
          end
        end

        it "includes role-specific permissions" do
          expected = mapper::ROLE_PERMISSIONS[role] || []
          expected.each do |perm|
            expect(principal.allowed?(perm)).to be(true),
              "#{role} should have #{perm}"
          end
        end

        it "does not include permissions from other roles" do
          all_possible = mapper::ROLE_PERMISSIONS.values.flatten.uniq
          own_perms = mapper::BASE_PERMISSIONS + (mapper::ROLE_PERMISSIONS[role] || [])
          forbidden = all_possible - own_perms

          forbidden.each do |perm|
            expect(principal.allowed?(perm)).to be(false),
              "#{role} should NOT have #{perm}"
          end
        end
      end
    end
  end

  # -------------------------------------------------------------------------
  # Edge cases
  # -------------------------------------------------------------------------
  describe "edge cases" do
    it "returns guest for blank token" do
      snapshot = mapper.from_bearer("")
      expect(snapshot.principal.guest?).to be true
    end

    it "returns guest for missing email in JWT" do
      token = build_jwt("id" => "no-email", "roles" => ["admin"])
      snapshot = mapper.from_bearer(token)
      expect(snapshot.principal.guest?).to be true
    end

    it "gives only base permissions for unrecognized roles" do
      token = build_jwt(
        "id" => "unknown-1",
        "email" => "unknown@clinic.com",
        "roles" => ["random_role"]
      )
      snapshot = mapper.from_bearer(token)
      principal = snapshot.principal

      expect(principal.guest?).to be false
      expect(principal.dental_roles).to be_empty
      mapper::BASE_PERMISSIONS.each do |perm|
        expect(principal.allowed?(perm)).to be true
      end
      expect(principal.allowed?("dental:workflow:write")).to be false
    end

    it "merges permissions for multi-role users" do
      token = build_jwt(
        "id" => "multi-1",
        "email" => "multi@clinic.com",
        "roles" => %w[dentist cashier]
      )
      snapshot = mapper.from_bearer(token)
      principal = snapshot.principal

      expect(principal.dental_roles).to match_array(%w[cashier dentist])
      expect(principal.allowed?("dental:clinical:write")).to be true
      expect(principal.allowed?("dental:billing:sync")).to be true
    end

    it "handles case-insensitive roles" do
      token = build_jwt(
        "id" => "upper-1",
        "email" => "upper@clinic.com",
        "roles" => ["ADMIN"]
      )
      snapshot = mapper.from_bearer(token)
      expect(snapshot.principal.allowed?("admin:access")).to be true
    end

    it "handles nil/empty roles gracefully" do
      token = build_jwt(
        "id" => "nil-roles",
        "email" => "noroles@clinic.com",
        "roles" => nil
      )
      snapshot = mapper.from_bearer(token)
      principal = snapshot.principal

      expect(principal.guest?).to be false
      expect(principal.dental_roles).to be_empty
    end
  end

  # -------------------------------------------------------------------------
  # Principal.dental_roles
  # -------------------------------------------------------------------------
  describe "Principal#dental_roles" do
    it "returns only recognized dental roles" do
      principal = Security::Principal.new(
        id: "1", email: "test@test.com", display_name: "Test",
        roles: %w[admin random_role dentist unknown],
        permissions: []
      )
      expect(principal.dental_roles).to match_array(%w[admin dentist])
    end

    it "returns empty array for guest" do
      expect(Security::Principal.guest.dental_roles).to be_empty
    end
  end

  # -------------------------------------------------------------------------
  # Deny-by-default: empty permissions trigger policy denial
  # -------------------------------------------------------------------------
  describe "deny-by-default with empty permissions" do
    let(:principal) do
      Security::Principal.new(
        id: "deny-test", email: "deny@test.com", display_name: "Deny",
        roles: [], permissions: []
      )
    end

    it "denies all dental policy actions" do
      expect(Dental::VisitPolicy.new(principal, :v).show?).to be false
      expect(Dental::ClinicalPolicy.new(principal, :c).read?).to be false
      expect(Dental::BillingPolicy.new(principal, :b).index?).to be false
      expect(Dental::RequisitionPolicy.new(principal, :r).index?).to be false
      expect(Dental::PrintPolicy.new(principal, :p).show?).to be false
    end
  end
end
