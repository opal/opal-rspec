rspec_filter 'nil_expectation_warning' do
  # marshal not supported on Opal, other issues were fixed in 0.9 that allow this to pass
  filter '#allow_message_expectations_on_nil doesnt error when marshalled'

  # backtrace / line number
  filter 'an expectation set on nil issues a warning with file and line number information'
end
