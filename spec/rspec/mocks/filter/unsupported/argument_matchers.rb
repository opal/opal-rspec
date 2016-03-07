rspec_filter 'argument_matchers' do
  # Fixnum == Float on Opal
  filter 'argument matchers matching handling non-matcher arguments fails a class against an object of a different type'

  # symbols and strings are different to this example but they are the same in Opal
  filter 'argument matchers matching handling non-matcher arguments fails for a hash w/ wrong keys'
end
