RSpec.configure do |config|
  config.default_formatter = ::RSpec::Core::Formatters::ProgressFormatter

  # # Have to do this in 2 places. This will ensure the default formatter gets the right IO, but need to do this here for custom formatters
  # # that will be constructed BEFORE Runner.autorun runs (see runner.rb)
  # config.output_stream = $stdout

  # This shouldn't be in here, but RSpec uses undef to change this configuration and that doesn't work well enough yet
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
