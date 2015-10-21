rspec_filter 'argument_matchers' do
  filter('argument matchers matching duck_type matches duck type with two methods').unless { at_least_opal_0_9? }
end
