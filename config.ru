require 'opal/rspec/sprockets_environment'

Opal::Processor.source_map_enabled = false

sprockets_env = Opal::RSpec::SprocketsEnvironment.new(spec_pattern='spec/opal/**/*_spec.{rb,opal}')
run Opal::Server.new(sprockets: sprockets_env) { |s|
  s.main = 'opal/rspec/sprockets_runner'
  sprockets_env.get_opal_spec_paths.each { |spec_path| s.append_path spec_path }
  s.debug = false
}
