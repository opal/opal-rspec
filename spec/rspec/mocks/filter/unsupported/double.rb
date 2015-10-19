rspec_filter 'double' do
  # private methods
  filter "RSpec::Mocks::Double does not respond_to? method_missing (because it's private)"

  # backtrace/line number
  filter /RSpec::Mocks::Double reports line number of expectation of unreceived message.*/

  # depends on eval
  filter 'RSpec::Mocks::Double fails when calling yielding method with invalid kw args'

  # throw not supported on Opal 0.8
  filter('RSpec::Mocks::Double throws when told to').unless { at_least_opal_0_9? }

  # private methods
  filter('RSpec::Mocks::Double has method_missing as private')
end
