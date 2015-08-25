require 'opal/rspec/cached_environment'
require 'opal/rspec/sprockets_environment'
require_relative 'spec/rspec_provided/opal_spec_loader'

Opal::Processor.source_map_enabled = false

files = Opal::RSpec::OpalSpecLoader.get_file_list
with_sub = Opal::RSpec::OpalSpecLoader.sub_in_end_of_line files
sprockets_env = Opal::RSpec::SprocketsEnvironment.new(spec_pattern=nil,spec_exclude_pattern=nil,spec_files=with_sub)
run Opal::Server.new(sprockets: sprockets_env) { |s|
  s.main = 'opal/rspec/sprockets_runner'
  Opal::RSpec::OpalSpecLoader.stub_requires
  sprockets_env.get_opal_spec_paths.each { |spec_path| s.append_path spec_path }
  Opal::RSpec::OpalSpecLoader.append_additional_load_paths s
  puts "Opal load path is #{s.sprockets.paths}"
  s.debug = ENV['OPAL_DEBUG']
}
