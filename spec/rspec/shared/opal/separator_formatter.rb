module Opal::RSpec
  # a good compromise between not mucking with the code we're testing but making it more machine readable
  class SeparatorFormatter < ::RSpec::Core::Formatters::BaseFormatter
    ::RSpec::Core::Formatters.register self, :close
    SEP = "~~~SEPARATOR~~~"

    def close(_notification)
      output.puts # our dots will not have closed out with a CR
      output.puts SEP
      output.sync = true
      output.puts # Need a CR for popen to know we're done
    end
  end
end
