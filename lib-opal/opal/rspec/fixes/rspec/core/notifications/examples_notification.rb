module ::RSpec::Core::Notifications
  class ExamplesNotification
    def fully_formatted_pending_examples(colorizer=::RSpec::Core::Formatters::ConsoleCodes)
      formatted = "\nPending: (Failures listed here are expected and do not affect your suite's status)\n".dup

      pending_notifications.each_with_index do |notification, index|
        formatted += notification.fully_formatted(index.next, colorizer)
      end

      formatted
    end
  end
end
