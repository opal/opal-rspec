require 'opal/rspec'
require 'opal-sprockets'
require 'opal/sprockets/server'

root = File.expand_path("#{__dir__}/../..")

Opal::Config.source_map_enabled = false
sprockets = Opal::RSpec::SprocketsEnvironment.new('spec-opal/*_spec.{rb,opal}')
sprockets.add_spec_paths_to_sprockets

run Opal::Sprockets::Server.new(sprockets: sprockets) { |s|
  s.main = 'sprockets_runner_js_errors'
  s.debug = ENV['OPAL_DEBUG']
}
