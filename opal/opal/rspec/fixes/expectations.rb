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

  exception = RSpec::Expectations::ExpectationNotMetError.new(message)
  # we can't throw exceptions when testing asynchronously and we need to be able to get them back to the example. class variables are one way to do this. better way?

  current_example = ::RSpec.current_example
  if current_example.is_a? Opal::RSpec::AsyncExample
    current_example.notify_async_exception exception
  else
    raise exception
  end
end
