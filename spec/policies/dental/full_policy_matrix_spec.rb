require "rails_helper"

RSpec.describe "Full Pundit policy matrix for 9 dental roles" do
  # -----------------------------------------------------------------------
  # Role → Permission mapping (mirrors SessionSnapshotMapper::ROLE_PERMISSIONS)
  # -----------------------------------------------------------------------
  ROLE_PERMISSIONS = Backend::Mappers::SessionSnapshotMapper::ROLE_PERMISSIONS
  BASE_PERMISSIONS = Backend::Mappers::SessionSnapshotMapper::BASE_PERMISSIONS

  ALL_ROLES = %w[
    dentist dental_assistant hygienist registration cashier
    pharmacist admin admin_finance clinic_manager
  ].freeze

  def principal_for(role)
    perms = BASE_PERMISSIONS + (ROLE_PERMISSIONS[role] || [])
    Security::Principal.new(
      id: "test-#{role}",
      email: "#{role}@test.com",
      display_name: role.tr("_", " ").capitalize,
      roles: [role],
      permissions: perms
    )
  end

  def guest_principal
    Security::Principal.guest
  end

  # -----------------------------------------------------------------------
  # Dental::HomePolicy
  # -----------------------------------------------------------------------
  describe Dental::HomePolicy do
    ALL_ROLES.each do |role|
      it "allows show? for #{role}" do
        policy = described_class.new(principal_for(role), :home)
        expect(policy.show?).to be(true), "#{role} should be allowed dental:read (show?)"
      end
    end

    it "denies show? for guest" do
      expect(described_class.new(guest_principal, :home).show?).to be false
    end
  end

  # -----------------------------------------------------------------------
  # Dental::VisitPolicy
  # -----------------------------------------------------------------------
  describe Dental::VisitPolicy do
    # show? requires dental:workflow:read — all roles have this via base
    ALL_ROLES.each do |role|
      it "allows show? for #{role}" do
        policy = described_class.new(principal_for(role), :visit)
        expect(policy.show?).to be(true), "#{role} should be allowed dental:workflow:read (show?)"
      end
    end

    # transition? / check_in? / sync_appointments? require dental:workflow:write
    write_roles = %w[dentist dental_assistant hygienist registration cashier admin clinic_manager]
    deny_write  = ALL_ROLES - write_roles

    write_roles.each do |role|
      it "allows transition? for #{role}" do
        policy = described_class.new(principal_for(role), :visit)
        expect(policy.transition?).to be(true), "#{role} should be allowed dental:workflow:write (transition?)"
      end

      it "allows check_in? for #{role}" do
        policy = described_class.new(principal_for(role), :visit)
        expect(policy.check_in?).to be(true), "#{role} should be allowed dental:workflow:write (check_in?)"
      end

      it "allows sync_appointments? for #{role}" do
        policy = described_class.new(principal_for(role), :visit)
        expect(policy.sync_appointments?).to be(true)
      end
    end

    deny_write.each do |role|
      it "denies transition? for #{role}" do
        policy = described_class.new(principal_for(role), :visit)
        expect(policy.transition?).to be(false), "#{role} should NOT have dental:workflow:write"
      end

      it "denies check_in? for #{role}" do
        policy = described_class.new(principal_for(role), :visit)
        expect(policy.check_in?).to be(false)
      end
    end

    it "denies all write actions for guest" do
      policy = described_class.new(guest_principal, :visit)
      expect(policy.show?).to be false
      expect(policy.transition?).to be false
      expect(policy.check_in?).to be false
    end
  end

  # -----------------------------------------------------------------------
  # Dental::ClinicalPolicy
  # -----------------------------------------------------------------------
  describe Dental::ClinicalPolicy do
    read_roles  = %w[dentist dental_assistant hygienist admin clinic_manager]
    write_roles = %w[dentist dental_assistant admin]
    deny_read   = ALL_ROLES - read_roles
    deny_write  = ALL_ROLES - write_roles

    read_roles.each do |role|
      it "allows read? for #{role}" do
        policy = described_class.new(principal_for(role), :clinical)
        expect(policy.read?).to be(true), "#{role} should have dental:clinical:read"
      end
    end

    deny_read.each do |role|
      it "denies read? for #{role}" do
        policy = described_class.new(principal_for(role), :clinical)
        expect(policy.read?).to be(false), "#{role} should NOT have dental:clinical:read"
      end
    end

    write_roles.each do |role|
      it "allows write? for #{role}" do
        policy = described_class.new(principal_for(role), :clinical)
        expect(policy.write?).to be(true), "#{role} should have dental:clinical:write"
      end
    end

    deny_write.each do |role|
      it "denies write? for #{role}" do
        policy = described_class.new(principal_for(role), :clinical)
        expect(policy.write?).to be(false), "#{role} should NOT have dental:clinical:write"
      end
    end

    it "denies all for guest" do
      policy = described_class.new(guest_principal, :clinical)
      expect(policy.read?).to be false
      expect(policy.write?).to be false
    end
  end

  # -----------------------------------------------------------------------
  # Dental::BillingPolicy
  # -----------------------------------------------------------------------
  describe Dental::BillingPolicy do
    read_roles = %w[cashier admin admin_finance clinic_manager]
    sync_roles = %w[cashier admin admin_finance]
    deny_read  = ALL_ROLES - read_roles
    deny_sync  = ALL_ROLES - sync_roles

    read_roles.each do |role|
      it "allows index? for #{role}" do
        policy = described_class.new(principal_for(role), :billing)
        expect(policy.index?).to be(true), "#{role} should have dental:billing:read"
      end

      it "allows show? for #{role}" do
        policy = described_class.new(principal_for(role), :billing)
        expect(policy.show?).to be(true)
      end
    end

    deny_read.each do |role|
      it "denies index? for #{role}" do
        policy = described_class.new(principal_for(role), :billing)
        expect(policy.index?).to be(false), "#{role} should NOT have dental:billing:read"
      end
    end

    sync_roles.each do |role|
      it "allows sync? for #{role}" do
        policy = described_class.new(principal_for(role), :billing)
        expect(policy.sync?).to be(true), "#{role} should have dental:billing:sync"
      end
    end

    deny_sync.each do |role|
      it "denies sync? for #{role}" do
        policy = described_class.new(principal_for(role), :billing)
        expect(policy.sync?).to be(false), "#{role} should NOT have dental:billing:sync"
      end
    end

    it "denies all for guest" do
      policy = described_class.new(guest_principal, :billing)
      expect(policy.index?).to be false
      expect(policy.sync?).to be false
    end
  end

  # -----------------------------------------------------------------------
  # Dental::RequisitionPolicy
  # -----------------------------------------------------------------------
  describe Dental::RequisitionPolicy do
    read_roles     = %w[dentist pharmacist admin clinic_manager]
    write_roles    = %w[dentist pharmacist admin]
    approve_roles  = %w[pharmacist admin clinic_manager]
    dispense_roles = %w[pharmacist admin]
    receive_roles  = %w[pharmacist admin]

    read_roles.each do |role|
      it "allows index? for #{role}" do
        policy = described_class.new(principal_for(role), :requisition)
        expect(policy.index?).to be(true), "#{role} should have dental:requisition:read"
      end
    end

    (ALL_ROLES - read_roles).each do |role|
      it "denies index? for #{role}" do
        policy = described_class.new(principal_for(role), :requisition)
        expect(policy.index?).to be(false), "#{role} should NOT have dental:requisition:read"
      end
    end

    write_roles.each do |role|
      it "allows create? for #{role}" do
        policy = described_class.new(principal_for(role), :requisition)
        expect(policy.create?).to be(true), "#{role} should have dental:requisition:write"
      end
    end

    (ALL_ROLES - write_roles).each do |role|
      it "denies create? for #{role}" do
        policy = described_class.new(principal_for(role), :requisition)
        expect(policy.create?).to be(false), "#{role} should NOT have dental:requisition:write"
      end
    end

    approve_roles.each do |role|
      it "allows approve? for #{role}" do
        policy = described_class.new(principal_for(role), :requisition)
        expect(policy.approve?).to be(true), "#{role} should have dental:requisition:approve"
      end
    end

    (ALL_ROLES - approve_roles).each do |role|
      it "denies approve? for #{role}" do
        policy = described_class.new(principal_for(role), :requisition)
        expect(policy.approve?).to be(false), "#{role} should NOT have dental:requisition:approve"
      end
    end

    dispense_roles.each do |role|
      it "allows dispense? for #{role}" do
        policy = described_class.new(principal_for(role), :requisition)
        expect(policy.dispense?).to be(true), "#{role} should have dental:requisition:dispense"
      end
    end

    (ALL_ROLES - dispense_roles).each do |role|
      it "denies dispense? for #{role}" do
        policy = described_class.new(principal_for(role), :requisition)
        expect(policy.dispense?).to be(false)
      end
    end

    receive_roles.each do |role|
      it "allows receive? for #{role}" do
        policy = described_class.new(principal_for(role), :requisition)
        expect(policy.receive?).to be(true), "#{role} should have dental:requisition:receive"
      end
    end

    (ALL_ROLES - receive_roles).each do |role|
      it "denies receive? for #{role}" do
        policy = described_class.new(principal_for(role), :requisition)
        expect(policy.receive?).to be(false)
      end
    end

    it "denies all for guest" do
      policy = described_class.new(guest_principal, :requisition)
      expect(policy.index?).to be false
      expect(policy.create?).to be false
      expect(policy.approve?).to be false
      expect(policy.dispense?).to be false
      expect(policy.receive?).to be false
    end
  end

  # -----------------------------------------------------------------------
  # Dental::PrintPolicy
  # -----------------------------------------------------------------------
  describe Dental::PrintPolicy do
    print_roles = %w[dentist dental_assistant hygienist registration cashier admin clinic_manager]
    deny_print  = ALL_ROLES - print_roles

    print_roles.each do |role|
      it "allows show? for #{role}" do
        policy = described_class.new(principal_for(role), :print)
        expect(policy.show?).to be(true), "#{role} should have dental:print:read"
      end
    end

    deny_print.each do |role|
      it "denies show? for #{role}" do
        policy = described_class.new(principal_for(role), :print)
        expect(policy.show?).to be(false), "#{role} should NOT have dental:print:read"
      end
    end

    it "denies show? for guest" do
      expect(described_class.new(guest_principal, :print).show?).to be false
    end
  end

  # -----------------------------------------------------------------------
  # Deny-by-default: Dental::BasePolicy
  # -----------------------------------------------------------------------
  describe Dental::BasePolicy do
    ALL_ROLES.each do |role|
      it "denies all base actions for #{role} (deny-by-default)" do
        policy = described_class.new(principal_for(role), :anything)
        expect(policy.access?).to be false
        expect(policy.index?).to be false
        expect(policy.show?).to be false
        expect(policy.create?).to be false
        expect(policy.update?).to be false
        expect(policy.destroy?).to be false
      end
    end
  end

  # -----------------------------------------------------------------------
  # Admin policies: only admin and clinic_manager
  # -----------------------------------------------------------------------
  describe "Admin policy access" do
    admin_roles = %w[admin clinic_manager]
    deny_admin  = ALL_ROLES - admin_roles

    admin_roles.each do |role|
      it "allows admin dashboard show? for #{role}" do
        policy = Admin::DashboardPolicy.new(principal_for(role), :dashboard)
        expect(policy.show?).to be(true), "#{role} should have admin:access"
      end
    end

    deny_admin.each do |role|
      it "denies admin dashboard show? for #{role}" do
        policy = Admin::DashboardPolicy.new(principal_for(role), :dashboard)
        expect(policy.show?).to be(false), "#{role} should NOT have admin:access"
      end
    end
  end

  # -----------------------------------------------------------------------
  # Verify mapper produces expected permissions per role
  # -----------------------------------------------------------------------
  describe "SessionSnapshotMapper role→permission mapping" do
    ALL_ROLES.each do |role|
      it "maps #{role} to expected permissions" do
        user_session = { "roles" => [role], "email" => "#{role}@test.com" }
        permissions = Backend::Mappers::SessionSnapshotMapper.send(:inject_bff_permissions, user_session)

        expected = (BASE_PERMISSIONS + (ROLE_PERMISSIONS[role] || [])).uniq
        expect(permissions).to match_array(expected)
      end
    end

    it "gives only base permissions for unrecognized roles" do
      user_session = { "roles" => ["unknown_role"], "email" => "u@test.com" }
      permissions = Backend::Mappers::SessionSnapshotMapper.send(:inject_bff_permissions, user_session)
      expect(permissions).to match_array(BASE_PERMISSIONS)
    end

    it "merges permissions for users with multiple roles" do
      user_session = { "roles" => %w[dentist cashier], "email" => "multi@test.com" }
      permissions = Backend::Mappers::SessionSnapshotMapper.send(:inject_bff_permissions, user_session)

      expect(permissions).to include("dental:clinical:write")
      expect(permissions).to include("dental:billing:sync")
    end

    it "normalizes role names case-insensitively" do
      user_session = { "roles" => ["ADMIN"], "email" => "upper@test.com" }
      permissions = Backend::Mappers::SessionSnapshotMapper.send(:inject_bff_permissions, user_session)
      expect(permissions).to include("admin:access")
    end
  end
end
