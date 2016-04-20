rspec_filter 'object_formatter' do
  # time format is off
  filter /RSpec::Support::ObjectFormatter with Time objects.*/

  # doesn't exist on Opal
  filter /RSpec::Support::ObjectFormatter with DateTime objects.*/
end
