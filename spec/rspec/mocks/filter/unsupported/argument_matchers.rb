rspec_filter 'argument_matchers' do
  # Fixnum == Float on Opal
  filter 'argument matchers matching handling non-matcher arguments fails a class against an object of a different type'
  filter('argument matchers matching instance_of handles non matching instances nicely').unless { at_least_opal_0_9? }
  filter('argument matchers matching instance_of does NOT accept float as instance_of(Numeric)').unless { at_least_opal_0_9? }
  filter('argument matchers matching instance_of does NOT accept fixnum as instance_of(Numeric)').unless { at_least_opal_0_9? }

  # symbols and strings are different to this example but they are the same in Opal
  filter 'argument matchers matching handling non-matcher arguments fails for a hash w/ wrong keys'
end
