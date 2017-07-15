require 'opal/rspec/async/async_example'
require 'opal/rspec/async/example_group'
require 'opal/rspec/async/hooks'
require 'opal/rspec/async/legacy'
require 'opal/rspec/async/reporter'
require 'opal/rspec/async/runner'

RSpec.configure do |config|
  # Legacy helpers
  config.include Opal::RSpec::AsyncHelpers
end
