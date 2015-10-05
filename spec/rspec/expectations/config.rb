require 'opal/progress_json_formatter' # verify case uses this

RSpec::configure do |config|
  config.color = true

  config.include FormattingSupport
  config.include RSpecHelpers

  config.expect_with :rspec do |expectations|
    $default_expectation_syntax = expectations.syntax
    expectations.syntax = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  #config.full_description = 'RSpec::Expectations::Configuration configuring rspec-expectations directly behaves like configuring the expectation syntax can limit the syntax to :should'
end
