require 'opal/rspec/rake_task'
require 'opal/rspec/sprockets_environment'
require_relative 'spec/rspec_provided/stubbing'

Opal::Processor.source_map_enabled = false

files = Opal::RSpec::Stubbing.get_file_list
with_sub = Opal::RSpec::Stubbing.sub_in_end_of_line files
sprockets_env = Opal::RSpec::SprocketsEnvironment.new(spec_pattern=nil,spec_exclude_pattern=nil,spec_files=with_sub)
run Opal::Server.new(sprockets: sprockets_env) { |s|
  s.main = 'opal/rspec/sprockets_runner'
  Opal::RSpec::Stubbing.stub_requires
  sprockets_env.get_opal_spec_paths.each { |spec_path| s.append_path spec_path }
  Opal::RSpec::Stubbing.append_additional_load_paths s
  puts "Opal load path is #{s.sprockets.paths}"
  s.debug = true
}
