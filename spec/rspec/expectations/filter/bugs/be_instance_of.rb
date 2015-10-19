rspec_filter 'be_instance_of' do
  unless at_least_opal_0_9?
    # Maybe Numeric shouldn't == Fixnum but it does in Opal
    filter('expect(actual).to be_an_instance_of(expected) fails if actual is instance of subclass of expected class')
    filter('expect(actual).to be_instance_of(expected) fails if actual is instance of subclass of expected class')
  end
end
