require 'opal/rspec/pre_require_fixes'
require 'opal/rspec/requires'
require 'opal/rspec/fixes'
require 'opal/rspec/text_formatter'
require 'opal/rspec/browser_formatter'
require 'opal/rspec/runner'
require 'opal/rspec/async'

RSpec.configure do |config|
  # For now, always use our custom formatter for results
  config.default_formatter = Opal::RSpec::Runner.default_formatter
  
  # Legacy helpers
  config.include Opal::RSpec::AsyncHelpers

  # Always support expect() and .should syntax (we should not do this really..)
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
