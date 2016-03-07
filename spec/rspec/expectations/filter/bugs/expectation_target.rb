rspec_filter 'expectation_target' do
  # Arity
  filter('RSpec::Expectations::ExpectationTarget when constructed via #expect raises a wrong number of args ArgumentError when given two args').unless { at_least_opal_0_10? }
end
