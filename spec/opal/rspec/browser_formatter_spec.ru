require 'opal/rspec/sprockets'
require 'opal/sprockets'
require 'opal/sprockets/server'

Opal::Config.source_map_enabled = false
Opal::Config.arity_check_enabled = true

sprockets = Opal::RSpec::SprocketsEnvironment.new('spec-opal/browser-formatter/*_spec.{rb,opal}')
sprockets.cache = ::Sprockets::Cache::FileStore.new('tmp/cache/opal_specs')
sprockets.add_spec_paths_to_sprockets

run Opal::Sprockets::Server.new(sprockets: sprockets) { |s|
  s.main = 'sprockets_runner_js_errors'
  # sprockets_runner_js_errors will not be in the opal load path by default
  # s.append_path 'spec/integration/rack'
  s.debug = true
}
