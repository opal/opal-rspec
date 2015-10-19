rspec_filter 'description_generation' do
  # Probably related to https://github.com/opal/opal/pull/1117
  filter('Matchers should be able to generate their own descriptions expect(...).to raise_error with type').unless { at_least_opal_0_9? }
end
