class ::RSpec::Core::Ordering::Random
  # there are a lot of these in the RSpec specs that create noise
  HIDE_RANDOM_WARNINGS = true
end

# dealing with dynamic requires
require 'rspec/support'
require 'rspec/support/spec/deprecation_helpers'
require 'rspec/support/spec/with_isolated_stderr'
require 'rspec/support/spec/stderr_splitter'
require 'rspec/support/spec/formatting_support'
require 'rspec/support/spec/with_isolated_directory'
require 'rspec/support/ruby_features'
# require 'support/shared_example_groups'
# require 'support/helper_methods'
# require 'support/matchers'
# require 'support/formatter_support'
# require 'sandboxing'
require 'fixes/missing_constants'
require 'fixes/shared_examples'
require 'rspec/support/spec'
require 'opal/fixes/deprecation_helpers'
require 'opal/fixes/rspec_helpers'
require 'filters'

RSpec.configure do |c|
  #c.full_description = 'uses the default color for the shared example backtrace line'
  c.add_formatter RSpec::Core::Formatters::JsonFormatter, '/tmp/rspec-support-results.json'
  c.add_formatter RSpec::Core::Formatters::ProgressFormatter, $stdout
end
