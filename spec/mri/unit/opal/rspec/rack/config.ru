require 'opal/rspec'

Opal::Processor.source_map_enabled = false

sprockets_env = Opal::RSpec::SprocketsEnvironment.new(spec_pattern='spec/mri/unit/opal/rspec/opal/browser_formatter_spec.rb')
run Opal::Server.new(sprockets: sprockets_env) { |s|
      s.main = 'opal/rspec/sprockets_runner'
      sprockets_env.add_spec_paths_to_sprockets
      s.debug = ENV['OPAL_DEBUG']
    }
