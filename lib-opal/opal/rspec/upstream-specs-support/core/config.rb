# require 'opal/progress_json_formatter' # verify case uses this
# require 'rspec/core/formatters'


module StubWriteFile
  def write_file(filename, content)
    # noop
  end
end

RSpec.configure do |config|
  #c.full_description = 'uses the default color for the shared example backtrace line'
  config.add_formatter RSpec::Core::Formatters::JsonFormatter, '/tmp/spec_results.json'
  config.add_formatter RSpec::Core::Formatters::ProgressFormatter, $stdout
  config.include StubWriteFile
  config.filter_run_excluding type: :drb
  config.filter_run_excluding isolated_directory: true
end
