rspec_filter 'expectations' do
  # Probably more related to nesting lambdas in the test than with using raise_error - https://github.com/opal/opal/pull/1117
  filter('RSpec::Expectations does not allow expectation failures to be caught by a bare rescue').unless { at_least_opal_0_10? }
end
