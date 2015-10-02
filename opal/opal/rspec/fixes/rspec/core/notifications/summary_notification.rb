module ::RSpec::Core::Notifications
  # SummaryNotification is a Struct
  SummaryNotification.class_eval do
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
