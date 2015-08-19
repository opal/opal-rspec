require 'opal/rspec/rake_task'

Opal::Processor.source_map_enabled = false

run Opal::Server.new { |s|
  s.main = 'opal/rspec/sprockets_runner'
  Opal::RSpec::RakeTask.get_opal_spec_paths.each { |spec_path| s.append_path spec_path }
  s.debug = false
}
