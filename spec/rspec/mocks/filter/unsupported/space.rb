rspec_filter 'space' do
  # no diff on Opal
  filter 'RSpec::Mocks::Space can be diffed in a failure when it has references to an error generator via a proxy'

  # mocking strings
  filter 'RSpec::Mocks::Space#proxies_of(klass) returns proxies'
end
