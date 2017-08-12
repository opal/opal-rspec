# string mutations
::RSpec::Core::Notifications::SummaryNotification.class_eval do
  def totals_line
    summary = ::RSpec::Core::Formatters::Helpers.pluralize(example_count, "example")
    summary += ", " + ::RSpec::Core::Formatters::Helpers.pluralize(failure_count, "failure")
    summary += ", #{pending_count} pending" if pending_count > 0
    summary
  end

  def fully_formatted(colorizer=::RSpec::Core::Formatters::ConsoleCodes)
    formatted = "\nFinished in #{formatted_duration} " \
                "(files took #{formatted_load_time} to load)\n" \
                "#{colorized_totals_line(colorizer)}\n"

    unless failed_examples.empty?
      formatted += colorized_rerun_commands(colorizer) + "\n"
    end

    formatted
  end
end
