rspec_filter 'combining_implementation_instructions' do
  # Opal does not support catch
  filter('Combining implementation instructions can combine and_yield and and_throw').unless { at_least_opal_0_9? }
  filter('Combining implementation instructions can combine and_yield, a block implementation and and_throw').unless { at_least_opal_0_9? }
  filter('Combining implementation instructions allows the terminal action to be overriden').unless { at_least_opal_0_9? }

  # line # / backtrace
  filter 'Combining implementation instructions warns when the inner implementation block is overriden'
end
