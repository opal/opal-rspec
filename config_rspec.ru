require 'opal/rspec'
require_relative 'spec/rspec_provided/opal_spec_loader'

Opal::Processor.source_map_enabled = false

files = Opal::RSpec::OpalSpecLoader.get_file_list
with_sub = Opal::RSpec::OpalSpecLoader.sub_in_end_of_line files
sprockets_env = Opal::RSpec::SprocketsEnvironment.new(spec_pattern=nil,spec_exclude_pattern=nil,spec_files=with_sub)
run Opal::Server.new(sprockets: sprockets_env) { |s|
  s.main = 'opal/rspec/sprockets_runner'
  Opal::RSpec::OpalSpecLoader.stub_requires
  sprockets_env.add_spec_paths_to_sprockets
  Opal::RSpec::OpalSpecLoader.append_additional_load_paths s
  s.debug = ENV['OPAL_DEBUG']
}
