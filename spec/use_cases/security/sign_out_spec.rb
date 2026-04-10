require "rails_helper"

RSpec.describe Security::SignOut do
  describe "#call" do
    it "clears the local session" do
      session = { Security::SessionStore::ACCESS_TOKEN_KEY => "token" }
      allow_any_instance_of(Backend::Providers::Local::SessionProvider).to receive(:sign_out)

      Security::SignOut.call(session:)

      expect(session[Security::SessionStore::ACCESS_TOKEN_KEY]).to be_nil
    end
  end
end
