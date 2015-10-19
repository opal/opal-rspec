rspec_filter 'stub' do
  # no throw in Opal
  unless at_least_opal_0_9?
    filter('A method stub throws with argument when told to')
    filter('A method stub throws when told to')
  end
end
