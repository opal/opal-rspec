class MiniTest
  class Unit; end
end

Test = MiniTest

require 'file'
require 'corelib/dir'
require 'thread'

require 'set'
require 'time'
require 'rbconfig'
require 'pathname'

# vendor a pre-built rspec
require 'opal/rspec/rspec'

# we "fix" these files, so require them now so they are loaded before our
# fixes file. We can't use Kernel#require() directly as the compiler will
# complain it can't find these files at compile time, but they are available
# from rspec.js from the gem.
%w[rspec
  rspec/core/formatters/base_text_formatter
  rspec/core/formatters/html_printer
  rspec/matchers/pretty
  rspec/matchers/built_in/base_matcher
  rspec/matchers/built_in/be].each { |r| `self.$require(r)` }

require 'opal/rspec/fixes'
require 'opal/rspec/text_formatter'
require 'opal/rspec/browser_formatter'
require 'opal/rspec/runner'
require 'opal/rspec/async'

RSpec.configure do |config|
  # For now, always use our custom formatter for results
  config.formatter = Opal::RSpec::Runner.default_formatter

  # Async helpers for specs
  config.include Opal::RSpec::AsyncHelpers
  config.extend Opal::RSpec::AsyncDefinitions

  # Always support expect() and .should syntax (we should not do this really..)
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
