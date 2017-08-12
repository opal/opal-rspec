# require 'opal/progress_json_formatter' # verify case uses this
# require 'rspec/core/formatters'

RSpec.configure do |c|
  #c.full_description = 'uses the default color for the shared example backtrace line'
  c.add_formatter RSpec::Core::Formatters::JsonFormatter, '/tmp/spec_results.json'
end
