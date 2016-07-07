rspec_filter 'dsl' do
  # mutable strings, see opal alternates
  filter 'RSpec::Matchers::DSL::Matcher defined using the dsl raises NoMethodError for methods not in the running_example'

  # Fixnum = Numeric on Opal, see opal alternates
  filter 'RSpec::Matchers::DSL::Matcher wrapping another expectation (expect(...).to eq ...) can use the `include` matcher from a `match` block'

  # regex compatibility, see opal alternates
  filter('RSpec::Matchers::DSL::Matcher wrapping another expectation (expect(...).to eq ...) can use the `match` matcher from a `match` block').unless { at_least_opal_0_11? }
end
