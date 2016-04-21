rspec_filter 'object_formatter' do
  # Opal doesn't have a 100% SimpleDelegator yet, so instead of expected "#<SimpleDelegator(#<Object:0x4c04>)>",
  # we get "#<Object(#<Object:0x4c04>)>"
  filter /RSpec::Support::ObjectFormatter given a delegator.*/

  # big decimal not there yet with formatting
  filter 'RSpec::Support::ObjectFormatter with BigDecimal objects fails with a conventional representation of the decimal'
end
