rspec_filter 'nil_expectation_warning' do
  # marshal not supported on Opal
  filter('#allow_message_expectations_on_nil does not affect subsequent examples').unless { at_least_opal_0_9? }
  filter '#allow_message_expectations_on_nil doesnt error when marshalled'

  # backtrace / line number
  filter 'an expectation set on nil issues a warning with file and line number information'
end
