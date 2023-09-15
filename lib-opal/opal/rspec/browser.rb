require 'opal/rspec/formatter/browser_formatter'

RSpec.configure do |config|
  if OPAL_PLATFORM.nil?
    # We want the browser formatter ONLY for the real browser, not
    # our headless browser runners.
    config.default_formatter = ::Opal::RSpec::BrowserFormatter
  end
end
