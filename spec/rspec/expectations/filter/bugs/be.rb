rspec_filter 'be' do
  # Maybe Numeric shouldn't == Fixnum but it does in Opal
  filter('be_an_instance_of fails when class is higher up hierarchy').unless { at_least_opal_0_9? }
end
