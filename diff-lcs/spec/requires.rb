RSpec.configure do |config|
  config.add_formatter RSpec::Core::Formatters::JsonFormatter, File.open('/tmp/diff-lcs-results.json', 'w')
  config.add_formatter RSpec::Core::Formatters::ProgressFormatter, $stdout
end
