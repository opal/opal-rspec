require 'opal/rspec'

Opal::Processor.source_map_enabled = false

sprockets_env = Opal::RSpec::SprocketsEnvironment.new(spec_pattern='spec/opal/**/*_spec.{rb,opal}',
                                                      spec_exclude_pattern=nil,
                                                      spec_files=nil,
                                                      default_path='spec/opal')
run Opal::Server.new(sprockets: sprockets_env) { |s|
      s.main = 'sprockets_runner_js_errors'
      # sprockets_runner_js_errors will not be in the opal load path by default
      s.append_path 'spec/mri/integration/rack'
      sprockets_env.add_spec_paths_to_sprockets
      s.debug = ENV['OPAL_DEBUG']
    }
