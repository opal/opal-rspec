require 'opal/rspec'
require_relative 'mocks_spec_loader'

Opal::RSpec::MocksSpecLoader.run_rack_server self
