class ::RSpec::Core::Ordering::Random
  # there are a lot of these in the RSpec specs that create noise
  HIDE_RANDOM_WARNINGS = true
end

# dealing with dynamic requires
require 'spec_helper'
require 'rspec/support/spec/deprecation_helpers'
require 'rspec/support/spec/with_isolated_stderr'
require 'rspec/support/spec/formatting_support'
require 'rspec/support/spec/with_isolated_directory'
require 'opal-parser'
require 'fixes/shared_examples'
require 'fixes/no_const_hide'
require 'corelib/marshal'
require 'filters'

RSpec.configure do |c|
  #c.full_description = 'uses the default color for the shared example backtrace line'
  c.add_formatter RSpec::Core::Formatters::JsonFormatter, File.open('/tmp/rspec-mocks-results.json', 'w')
  c.add_formatter RSpec::Core::Formatters::ProgressFormatter, $stdout
end

