require 'opal/progress_json_formatter'

RSpec.configure do |c|
  c.formatter = Opal::RSpec::ProgressJsonFormatter
  #c.full_description = 'uses the default color for the shared example backtrace line'
end
