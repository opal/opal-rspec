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
require 'opal/rspec/upstream-specs-support/support/fixes/missing_constants'
require 'opal/rspec/upstream-specs-support/support/fixes/shared_examples'
require 'rspec/support/spec'
require 'opal/rspec/upstream-specs-support/support/config'
require 'opal/fixes/deprecation_helpers'
require 'opal/fixes/rspec_helpers'
require 'opal/rspec/upstream-specs-support/support/filters'
