require 'opal/rspec'
require_relative 'expectation_spec_loader'

Opal::RSpec::ExpectationSpecLoader.run_rack_server self
