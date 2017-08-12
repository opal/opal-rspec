RSpec.configure do |config|
  unsupported = [
    # extra method coming from opal
    "RSpec::Core::ExampleGroup minimizes the number of methods that users could inadvertantly overwrite",

    # unsupported source location
    'RSpec::Core::FilterManager#prune prefers location to exclusion filter',
    'RSpec::Core::FilterManager#prune prefers location to exclusion filter on entire group',

    # expects Proc#inspect to include source location
    'RSpec::Core::FilterManager#inclusions#description cleans up the description',
    'RSpec::Core::FilterManager#exclusions#description cleans up the description',
  ]

  bugs = [
  ]

  # config.filter_run_excluding :full_description => Regexp.union(expected_failures.map { |d| Regexp.new(d) })
  config.filter_run_excluding :full_description => -> desc { unsupported.include? desc }
  config.before(:each) { |example| pending "BUG" if bugs.include? example.metadata[:full_description] }
end
