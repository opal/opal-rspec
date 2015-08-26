# TODO: Break this out into separate files
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
  
  class FailedExampleNotification
    def fully_formatted(failure_number, colorizer=::RSpec::Core::Formatters::ConsoleCodes)
      formatted = "\n  #{failure_number}) #{description}\n"

      colorized_message_lines(colorizer).each do |line|
        # formatted << RSpec::Support::EncodedString.new("     #{line}\n", encoding_of(formatted))
        # string mutation
        formatted = formatted + RSpec::Support::EncodedString.new("     #{line}\n", encoding_of(formatted))
      end

      colorized_formatted_backtrace(colorizer).each do |line|
        # formatted << RSpec::Support::EncodedString.new("     #{line}\n", encoding_of(formatted))
        # string mutation
        formatted = formatted + RSpec::Support::EncodedString.new("     #{line}\n", encoding_of(formatted))
      end
      formatted
    end
    
    private   
    
    def add_shared_group_line(lines, colorizer)
      unless shared_group_line == ""
        # string mutation        
        lines = lines + colorizer.wrap(shared_group_line, RSpec.configuration.default_color)
      end
      lines
    end    
  end
  
  # SummaryNotification is a Struct
  SummaryNotification = Class.new(SummaryNotification) do
    def totals_line
      summary = Formatters::Helpers.pluralize(example_count, "example")
      # 2 string mutations
      summary = summary + ", " + Formatters::Helpers.pluralize(failure_count, "failure")
      # string mutation
      summary = summary + ", #{pending_count} pending" if pending_count > 0
      summary
    end
    
    def fully_formatted(colorizer=::RSpec::Core::Formatters::ConsoleCodes)
      formatted = "\nFinished in #{formatted_duration} " \
                  "(files took #{formatted_load_time} to load)\n" \
                  "#{colorized_totals_line(colorizer)}\n"

      unless failed_examples.empty?
        # 2 string mutations
        formatted = formatted + colorized_rerun_commands(colorizer) + "\n"
      end

      formatted
    end
  end
end
