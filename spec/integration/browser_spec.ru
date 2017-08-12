require 'opal/rspec'
require 'opal-sprockets'
require 'opal/sprockets/server'

Opal::Config.source_map_enabled = false
sprockets = Opal::RSpec::SprocketsEnvironment.new(
  # 'spec-opal/browser-formatter/opal_browser_formatter_spec.rb'
  # "spec-opal/**/*_spec.{rb,opal}"
  "spec-opal/*_spec.{rb,opal}"
)
puts sprockets.locator.get_spec_load_paths
sprockets.add_spec_paths_to_sprockets

root = File.expand_path("#{__dir__}/../..")

run Opal::Sprockets::Server.new(sprockets: sprockets) { |s|
  s.main = 'sprockets_runner_js_errors'
  s.debug = ENV['OPAL_DEBUG']
}
