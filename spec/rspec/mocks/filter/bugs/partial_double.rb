rspec_filter 'partial double' do
  # super/inheritance problems prevent verifying partial doubles except in cases where and_call_original is used
  filter 'when verify_partial_doubles configuration option is set allows the mock to raise an error with yield'
  filter 'when verify_partial_doubles configuration option is set allows stubbing and calls the stubbed implementation'
end
