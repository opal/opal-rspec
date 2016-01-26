class ::RSpec::Core::Ordering::Random
  # there are a lot of these in the RSpec specs that create noise
  HIDE_RANDOM_WARNINGS = true
end

require 'rspec/support/spec/deprecation_helpers'
require 'rspec/support/spec/with_isolated_stderr'
require 'rspec/support/spec/stderr_splitter'
require 'rspec/support/spec/formatting_support'
require 'opal/fixes/deprecation_helpers'
require 'opal/fixes/rspec_helpers'
require_relative 'fixes/missing_constants'
require_relative 'spec_helper'
require_relative 'config'
