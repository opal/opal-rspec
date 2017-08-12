module ::RSpec::Core::Notifications
  class ExamplesNotification
    def fully_formatted_failed_examples(colorizer=::RSpec::Core::Formatters::ConsoleCodes)
      formatted = "\nFailures:\n"

      failure_notifications.each_with_index do |failure, index|
        # string mutation
        formatted = formatted + failure.fully_formatted(index.next, colorizer)
      end

      formatted
    end
    
    def fully_formatted_pending_examples(colorizer=::RSpec::Core::Formatters::ConsoleCodes)
      formatted = "\nPending:\n"

      pending_examples.each do |example|
        formatted_caller = RSpec.configuration.backtrace_formatter.backtrace_line(example.location)

        # string mutation
        formatted = formatted +
          "  #{colorizer.wrap(example.full_description, :pending)}\n" \
          "    # #{colorizer.wrap(example.execution_result.pending_message, :detail)}\n" \
          "    # #{colorizer.wrap(formatted_caller, :detail)}\n"
      end

      formatted
    end
  end
end
