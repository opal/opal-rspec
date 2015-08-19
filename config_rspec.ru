require 'opal/rspec/rake_task'
require 'opal/rspec/sprockets_environment'
require_relative 'spec/rspec_provided/stubbing'

Opal::Processor.source_map_enabled = false

sprockets_env = Opal::RSpec::SprocketsEnvironment.new(spec_pattern='spec/rspec_provided/**/*_spec.rb')
run Opal::Server.new(sprockets: sprockets_env) { |s|
  s.main = 'opal/rspec/sprockets_runner'
  Opal::RSpec::Stubbing.stub_requires
  Opal::RSpec::Stubbing.append_paths s  
  sprockets_env.get_opal_spec_paths.each { |spec_path| s.append_path spec_path }
  s.debug = false
}
