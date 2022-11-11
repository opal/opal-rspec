class ::RSpec::Core::Ordering::Random
  # there are a lot of these in the RSpec specs that create noise
  HIDE_RANDOM_WARNINGS = true
end

class Proc
  def source_location
    ['(dummy)', 0]
  end
end

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
require 'fixes/shared_examples'
require 'support/matchers'
require 'spec_helper'
require 'filters'

RSpec.configure do |c|
  #c.full_description = 'uses the default color for the shared example backtrace line'
  c.add_formatter RSpec::Core::Formatters::JsonFormatter, File.open('/tmp/rspec-expectations-results.json', 'w')
  c.add_formatter RSpec::Core::Formatters::ProgressFormatter, $stdout
end
