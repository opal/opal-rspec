module Opal::RSpec
  # a good compromise between not mucking with the code we're testing but making it more machine readable
  class ProgressJsonFormatter < ::RSpec::Core::Formatters::JsonFormatter
    ::RSpec::Core::Formatters.register self, :message, :dump_summary, :dump_profile, :example_passed, :example_pending, :example_failed, :close, :stop

    def example_passed(_notification)
      output.print ::RSpec::Core::Formatters::ConsoleCodes.wrap('.', :success)
    end

    def example_pending(_notification)
      output.print ::RSpec::Core::Formatters::ConsoleCodes.wrap('*', :pending)
    end

    def example_failed(_notification)
      output.print ::RSpec::Core::Formatters::ConsoleCodes.wrap('F', :failure)
    end

    def start_dump(_notification)
      output.puts
    end

    def close(_notification)
      output.puts # our dots will not have closed out with a CR
      output.puts 'BEGIN JSON'
      output.puts @output_hash.to_json
    end
  end
end
