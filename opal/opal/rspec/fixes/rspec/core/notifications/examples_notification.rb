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
      formatted = "\nPending: (Failures listed here are expected and do not affect your suite's status)\n"

      pending_notifications.each_with_index do |notification, index|
        # string mutation
        formatted = formatted + notification.fully_formatted(index.next, colorizer)
      end

      formatted
    end
  end
end
