require 'opal/rspec'
require_relative 'support_spec_loader'

Opal::RSpec::SupportSpecLoader.run_rack_server self
