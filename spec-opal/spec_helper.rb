require 'opal/rspec/async'

RSpec::configure do |config|
  config.filter_run_including focus: true
  config.run_all_when_everything_filtered = true
  config.color = true
end
