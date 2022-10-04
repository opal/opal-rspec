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
require 'rspec/support/spec/in_sub_process'
require 'rspec/support/ruby_features'
require 'support/shared_example_groups'
require 'support/helper_methods'
require 'support/matchers'
require 'support/formatter_support'
require 'support/config_options_helper'
require 'fixes/missing_constants'
require 'fixes/shared_examples'
require 'rspec/support/spec'
require 'opal/fixes/deprecation_helpers'
require 'opal/fixes/rspec_helpers'
require 'filters'

module StubWriteFile
  def write_file(filename, content)
    # noop
  end
end

RSpec.configure do |config|
  #c.full_description = 'uses the default color for the shared example backtrace line'
  config.add_formatter RSpec::Core::Formatters::JsonFormatter, File.open('/tmp/rspec-core-results.json', 'w')
  config.add_formatter RSpec::Core::Formatters::ProgressFormatter, $stdout
  config.include StubWriteFile
  config.filter_run_excluding type: :drb
  config.filter_run_excluding isolated_directory: true
end
