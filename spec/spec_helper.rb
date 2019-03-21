require "bundler/setup"
require "crave"
require "pry"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :should
  end
end

RSpec::Matchers.alias_matcher :satisfy_dependency, :be_satisfies_dependency

def fixture_path(path)
  File.join(__dir__, 'fixtures', path)
end
