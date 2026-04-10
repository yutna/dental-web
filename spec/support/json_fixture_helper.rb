require "json"

module JsonFixtureHelper
  def json_fixture(relative_path)
    fixture_path = Rails.root.join("spec/fixtures", relative_path)
    JSON.parse(fixture_path.read)
  end
end

RSpec.configure do |config|
  config.include JsonFixtureHelper
end
