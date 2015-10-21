rspec_filter 'any_instance' do
  # Mock strings
  filter '#any_instance when stubbing core ruby objects works with the non-standard constructor ""'
  filter "#any_instance when stubbing core ruby objects works with the non-standard constructor ''"
  filter '#any_instance setting a message expectation does not set the expectation on every instance'
end
