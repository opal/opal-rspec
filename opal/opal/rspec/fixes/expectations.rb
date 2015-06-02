def (RSpec::Expectations).fail_with(message, expected=nil, actual=nil)
  if !message
    raise ArgumentError, "Failure message is nil. Does your matcher define the " +
                         "appropriate failure_message_for_* method to return a string?"
  end

  # HAD ALSO:
  # if actual && expected
  #   if all_strings?(actual, expected)
  #     if any_multiline_strings?(actual, expected)
  #       message # + "\nDiff:" + differ.diff_as_string(coerce_to_string(actual), coerce_to_string(expected))
  #     end
  #   elsif no_procs?(actual, expected) && no_numbers?(actual, expected)
  #     message # + "\nDiff:" + differ.diff_as_object(actual, expected)
  #   end
  # end

  # diff = differ.diff(actual, expected)
  # message = "#{message}\nDiff:#{diff}" unless diff.empty?
  raise RSpec::Expectations::ExpectationNotMetError, message
end
