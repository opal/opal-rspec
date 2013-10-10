require 'bundler'
Bundler.require

Opal::Processor.source_map_enabled = false
# Opal::Processor.const_missing_enabled = false
Opal::Processor.dynamic_require_severity = :warning

Opal.append_path 'app' # load first so stub files come before real rspec files
Opal.append_path 'opal' # load first so stub files come before real rspec files
Opal.use_gem 'rspec'
Opal.use_gem 'rspec-expectations'

run Opal::Server.new { |s|
  s.main = 'app'
  s.debug = true
}
