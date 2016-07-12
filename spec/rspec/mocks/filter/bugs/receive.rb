rspec_filter 'receive' do
  # can't change expect/should right now due to undef/Opal
  filter 'RSpec::Mocks::Matchers::Receive when used in a test framework without rspec-expectations can toggle the available syntax'

  filter('RSpec::Mocks::Matchers::Receive expect(...).to receive behaves like an expect syntax expectation behaves like a receive matcher allows chaining off a `do...end` block implementation to be provided').unless { at_least_opal_0_11? }
  filter('RSpec::Mocks::Matchers::Receive allow(...).to receive behaves like an expect syntax allowance behaves like a receive matcher allows chaining off a `do...end` block implementation to be provided').unless { at_least_opal_0_11? }
end
