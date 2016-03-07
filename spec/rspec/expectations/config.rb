require 'opal/progress_json_formatter' # verify case uses this

# Only doing this because this spec causes the runner itself to break
CAUSES_SPECS_TO_CRASH = [
    'RSpec::Expectations::Configuration#backtrace_formatter defaults to a null formatter when rspec-core is not loaded'
]

RSpec::configure do |config|
  config.color = true

  config.include FormattingSupport
  config.include RSpecHelpers

  config.expect_with :rspec do |expectations|
    $default_expectation_syntax = expectations.syntax
    expectations.syntax = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.filter_run_excluding full_description: Regexp.union(CAUSES_SPECS_TO_CRASH)
  #config.full_description = 'RSpec::Matchers once required includes itself in Minitest::Test'
end
