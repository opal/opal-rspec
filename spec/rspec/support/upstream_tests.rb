require 'opal-rspec'

module Opal::RSpec::UpstreamTests
end

pattern = File.expand_path('../upstream_tests/**/*.rb', __FILE__)
Dir[pattern].each { |f| require f }
