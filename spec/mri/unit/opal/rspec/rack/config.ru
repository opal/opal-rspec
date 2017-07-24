require 'opal/rspec'
require 'opal-sprockets'
require 'opal/sprockets/server'

Opal::Config.source_map_enabled = false
sprockets = Opal::RSpec::SprocketsEnvironment.new(
  'spec/mri/unit/opal/rspec/opal/opal_browser_formatter_spec.rb'
)
sprockets.add_spec_paths_to_sprockets

root = File.expand_path("#{__dir__}/../../../../../..")

run Opal::Sprockets::Server.new(sprockets: sprockets) { |s|
  # sprockets_runner_js_errors will not be in the opal load path by default
  # s.append_path "#{root}/spec/mri/integration/rack"

  s.main = 'mri/integration/rack/sprockets_runner_js_errors'

  s.debug = ENV['OPAL_DEBUG']
}
