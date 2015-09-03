# dealing with dynamic requires
require 'rspec/support'
require 'rspec/support/spec/deprecation_helpers'
require 'rspec/support/spec/with_isolated_stderr'
require 'rspec/support/spec/stderr_splitter'
require 'rspec/support/spec/formatting_support'
require 'rspec/support/spec/with_isolated_directory'
require 'rspec/support/ruby_features'
require 'support/shared_example_groups'
require 'support/helper_methods'
require 'support/matchers'
require 'sandboxing'

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
  # will make it easier to exclude certain specs
  c.default_formatter = ::RSpec::Core::Formatters::DocumentationFormatter if Opal::RSpec::Runner.phantom?
end
# end RSpec config

# Do not have the mathn standard library
require 'support/formatter_support'
module MathnIntegrationSupport
  def with_mathn_loaded
    yield
  end
end

# the safety method is defined in helper_methods and uses threads
module RSpecHelpers
  def safely
    yield
  end
end

# Since our call site (locating which line a test is on does not yet work, we don't want to fail all of these mocks)
module RSpecHelpers
  def expect_deprecation_with_call_site(file, line, snippet=//)
    expect(RSpec.configuration.reporter).to receive(:deprecation) do |options|
      #expect(options[:call_site]).to include([file, line].join(':'))
      expect(options[:deprecated]).to match(snippet)
    end
  end

  def expect_deprecation_without_call_site(snippet=//)
    expect(RSpec.configuration.reporter).to receive(:deprecation) do |options|
      #expect(options[:call_site]).to eq nil
      expect(options[:deprecated]).to match(snippet)
    end
  end

  def expect_warn_deprecation_with_call_site(file, line, snippet=//)
    expect(RSpec.configuration.reporter).to receive(:deprecation) do |options|
      message = options[:message]
      expect(message).to match(snippet)
      #expect(message).to include([file, line].join(':'))
    end
  end

  def expect_warning_with_call_site(file, line, expected=//)
    expect(::Kernel).to receive(:warn) do |message|
      expect(message).to match expected
      #expect(message).to match(/Called from #{file}:#{line}/)
    end
  end
end

# RSpec::Core::ExampleGroup setting pending metadata in parent marks every example as pending
# This opal-rspec test failure is happening because 'fail' in opal does not behave correctly
# https://github.com/opal/opal/pull/1105
module Kernel
  def fail(message=nil)
    if message
      raise message
    else
      raise RuntimeError.new
    end
  end
end

# https://github.com/opal/opal/issues/1110
class ::RSpec::Core::HooksHost
  include Hooks

  def parent_groups
    []
  end
end

# Fixed in Opal 0.9
# https://github.com/opal/opal/commit/a6ec3164fcbb0f98ef46d385ea06bf0591828f23)
unless Object.const_defined? :ZeroDivisionError
  class ZeroDivisionError   < StandardError; end
end

# https://github.com/opal/opal/commit/5a17a12de1d3af45e189d34994a047fb7c1b4c72
unless Object.const_defined? :SecurityError
  class SecurityError < Exception;end
end
