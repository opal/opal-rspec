rspec_filter 'support' do
  # evals code
  filter 'RSpec::Support behaves like a library that issues no warnings when loaded issues no warnings when loaded'

  # undef'ing methods not working yet on Opal
  filter('RSpec::Support.method_handle_for(object, method_name) fails with `NameError` when a method is fetched from an object that has overriden `method` to not return a method').unless { at_least_opal_0_9? }
end
