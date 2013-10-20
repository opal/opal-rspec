require 'file'
require 'dir'
require 'thread'

# vendor a pre-built rspec
require 'opal/rspec/rspec'

require 'opal/rspec/fixes'
require 'opal/rspec/text_formatter'
require 'opal/rspec/browser_formatter'
require 'opal/rspec/runner'

RSpec.configure do |config|
  # For now, always use our custom formatter for results
  config.formatter = Opal::RSpec::Runner.default_formatter

  # Always support expect() and .should syntax (we should not do this really..)
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
