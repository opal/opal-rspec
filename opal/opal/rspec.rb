require 'opal/rspec/pre_require_fixes'
require 'opal/rspec/requires'
require 'opal/rspec/fixes'
require 'opal/rspec/formatter/browser_formatter'
require 'opal/rspec/runner'
require 'opal/rspec/async'

RSpec.configure do |config|
  config.default_formatter = ::RSpec::Core::Runner.non_browser? ? ::RSpec::Core::Formatters::ProgressFormatter : ::Opal::RSpec::BrowserFormatter

  # Have to do this in 2 places. This will ensure the default formatter gets the right IO, but need to do this here for custom formatters
  # that will be constructed BEFORE Runner.autorun runs (see runner.rb)
  _, stdout = ::RSpec::Core::Runner.get_opal_closed_tty_io
  config.output_stream = stdout

  # Legacy helpers
  config.include Opal::RSpec::AsyncHelpers
end
