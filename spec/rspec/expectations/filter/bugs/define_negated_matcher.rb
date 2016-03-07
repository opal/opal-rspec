rspec_filter 'define_negated_matcher' do
  # method owner (no issue/PR) and block (https://github.com/opal/opal/pull/1132)
  filter('RSpec::Matchers.define_negated_matcher when the negated description is overriden overrides the failure message with the provided block')
  filter('RSpec::Matchers.define_negated_matcher when no block is passed when matched negatively fails matches against values that pass the original matcher')
  filter('RSpec::Matchers.define_negated_matcher when no block is passed when matched positively fails matches against values that pass the original matcher')
  filter('RSpec::Matchers.define_negated_matcher the failure message for a matcher with default failure messages when failing negatively uses the phrasing from the provided defined matcher alias')
  filter('RSpec::Matchers.define_negated_matcher the failure message for a matcher with default failure messages when failing positively uses the phrasing from the provided defined matcher alias')
end
