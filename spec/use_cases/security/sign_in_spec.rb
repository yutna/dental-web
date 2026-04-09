require "rails_helper"

RSpec.describe Security::SignIn do
  let(:provider_registry) { instance_double(Backend::ProviderRegistry, session_provider:) }
  subject(:use_case) { described_class.new(provider_registry:) }

  context "when provider rejects credentials" do
    let(:session_provider) do
      Class.new do
        def sign_in(email:, password:)
            raise Backend::Errors::AuthenticationError, "Invalid backend credentials"
        end
      end.new
    end

    it "maps error to InvalidCredentialsError" do
      expect do
        use_case.call(email: "user@example.com", password: "invalid")
      end.to raise_error(Security::SignIn::InvalidCredentialsError)
    end
  end

  context "when canonical permissions are missing" do
    let(:session_provider) do
      Class.new do
        def sign_in(email:, password:)
          principal = Security::Principal.new(
            id: "abc",
            email: email,
            display_name: "User",
            roles: [ "clinician" ],
            permissions: []
          )

          Security::SessionSnapshot.new(
            access_token: "token",
            refresh_token: "refresh",
            principal: principal
          )
        end
      end.new
    end

    it "raises contract mismatch error" do
      expect do
        use_case.call(email: "user@example.com", password: "secret")
      end.to raise_error(Backend::Errors::ContractMismatchError)
    end
  end
end
