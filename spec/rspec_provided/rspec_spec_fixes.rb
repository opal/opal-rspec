require 'rspec/support'
require 'rspec/support/spec/deprecation_helpers'
require 'rspec/support/spec/with_isolated_stderr'
require 'rspec/support/spec/stderr_splitter'
require 'rspec/support/spec/formatting_support'
require 'rspec/support/spec/with_isolated_directory'
require 'rspec/support/ruby_features'
require 'support/shared_example_groups'
# begin mocks
class ::Dir
  def self.[](index)
    []
  end
end

module Aruba
  module Api
  end
end

module RSpec::Support::ShellOut
end

# end mocks
# begin 'mocked' examples
RSpec.shared_examples_for "a library that issues no warnings when loaded" do |lib, *preamble_stmnts|
end
# end 'mocked' examples

# begin RSpec config
require 'rspec/support/spec'
RSpec.configure do |c|
  # excludes
  
end
# end RSpec config
