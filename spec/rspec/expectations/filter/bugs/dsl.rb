rspec_filter 'dsl' do
  filter('RSpec::Matchers::DSL::Matcher allows chainable methods to accept blocks').unless { at_least_opal_0_10? }

  # something w/ inheritance is wrong here
  filter 'RSpec::Matchers::DSL::Matcher defined using the dsl can get a method object for methods in the running example'

  # probably class scoping issue since new_matcher creates a new DSL matcher class, probably https://github.com/opal/opal/issues/1110 related
  filter('RSpec::Matchers::DSL::Matcher#match_unless_raises without a specified error class passes if no error is raised').unless { at_least_opal_0_10? }

  # not sure, class scoping issue? (see above)
  filter('RSpec::Matchers::DSL::Matcher#match_unless_raises with an unexpected error raises the error').unless { at_least_opal_0_10? }
  filter('RSpec::Matchers::DSL::Matcher#match_unless_raises with an assertion with passing assertion passes').unless { at_least_opal_0_10? }
  filter('RSpec::Matchers::DSL::Matcher with an included module allows multiple modules to be included at once').unless { at_least_opal_0_10? }
  filter('RSpec::Matchers::DSL::Matcher allows an early `return` to be used from a `match_unless_raises` block').unless { at_least_opal_0_10? }
end
