require 'opal/rspec/formatter/browser_formatter'

RSpec.configure do |config|
  config.default_formatter = ::Opal::RSpec::BrowserFormatter
end
