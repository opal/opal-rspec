rspec_filter 'object_formatter' do
  # Opal doesn't have a 100% SimpleDelegator yet, so instead of expected "#<SimpleDelegator(#<Object:0x4c04>)>",
  # we get "#<Object(#<Object:0x4c04>)>"
  filter /RSpec::Support::ObjectFormatter given a delegator.*/
end
