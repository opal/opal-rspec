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
require 'opal/rspec/upstream-specs-support/core/fixes/shared_examples'
require 'corelib/marshal'
require_relative 'config'
require_relative 'filters'
