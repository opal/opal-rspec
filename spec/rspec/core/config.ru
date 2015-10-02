require 'opal/rspec'
require_relative 'core_spec_loader'

Opal::RSpec::CoreSpecLoader.run_rack_server self
