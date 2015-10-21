rspec_filter 'methods' do
  # can't change expect/should right now due to undef/Opal until 0.9
  filter('Methods added to every object limits the number of methods that get added to all objects').unless { at_least_opal_0_9? }
end

