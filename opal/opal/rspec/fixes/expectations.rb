def (RSpec::Expectations).fail_with(message, expected=nil, actual=nil)
  if !message
    raise ArgumentError, "Failure message is nil. Does your matcher define the " +
                         "appropriate failure_message_for_* method to return a string?"
  end
  
  # diff = differ.diff(actual, expected)
  # message = "#{message}\nDiff:#{diff}" unless diff.empty?
  raise RSpec::Expectations::ExpectationNotMetError, message
end
