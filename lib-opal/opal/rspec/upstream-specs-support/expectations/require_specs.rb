class ::RSpec::Core::Ordering::Random
  # there are a lot of these in the RSpec specs that create noise
  HIDE_RANDOM_WARNINGS = true
end

`Opal.loaded(['support/capybara'])`

require 'corelib/marshal'
require 'rspec/core'
require "rspec/support/spec/deprecation_helpers"
require "rspec/support/spec/with_isolated_stderr"
require "rspec/support/spec/stderr_splitter"
require "rspec/support/spec/formatting_support"
require "rspec/support/spec/with_isolated_directory"
require "rspec/support/ruby_features"
require 'rspec/support/spec'
require 'rspec/core/formatters/helpers'
require 'opal/rspec/upstream-specs-support/core/fixes/shared_examples'
require 'support/matchers'
require 'support/shared_examples'
require 'spec_helper'
require_relative 'config'
require_relative 'filters'
