rspec_filter 'mocks' do
  # Dir usage
  filter 'RSpec::Mocks behaves like a library that issues no warnings when loaded issues no warnings when loaded'

  # string mocking
  filter 'RSpec::Mocks.teardown resets method stubs'
  filter 'RSpec::Mocks.with_temporary_scope in a before(:all) with an any_instance stub allows the stub to be used'
end
