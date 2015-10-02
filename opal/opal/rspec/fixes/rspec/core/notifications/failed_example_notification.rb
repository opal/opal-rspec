module ::RSpec::Core::Notifications
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
  end
end
