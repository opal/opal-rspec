require 'opal/rspec/formatter/browser_formatter'

RSpec.configure do |config|
  config.default_formatter = ::Opal::RSpec::BrowserFormatter
end

# Trigger #at_exit callbacks once the DOM is ready
kernel_exit = -> _ { Kernel.exit unless defined? RSpec::OpalAsync }
if JS[:document].JS[:readyState] == :complete
  JS[:setTimeOut].call(kernel_exit, 1)
else
  JS[:document].JS.addEventListener('DOMContentLoaded', kernel_exit, false)
end
