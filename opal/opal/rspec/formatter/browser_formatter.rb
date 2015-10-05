require_relative 'document_io'
require_relative 'html_printer'

module Opal
  module RSpec
    class BrowserFormatter < ::RSpec::Core::Formatters::HtmlFormatter
      ::RSpec::Core::Formatters.register self, :example_group_finished

      def initialize(output)
        super DocumentIO.new
        @printer = Opal::RSpec::HtmlPrinter.new(@output)
      end

      def example_group_started(notification)
        # Since we hook print_example_group_end, we override this method
        @example_group_red = false
        @example_group_number += 1

        @printer.print_example_group_start(example_group_number, notification.group.description, notification.group.parent_groups.size)
        @printer.flush
      end

      def example_group_finished(notification)
        @printer.print_example_group_end
      end

      def start_dump(_notification)
        # Don't need to call "print_example_group_end" like base does since we hook that event
      end

      def extra_failure_content(failure)
        backtrace = failure.exception.backtrace.map { |line| ::RSpec.configuration.backtrace_formatter.backtrace_line(line) }
        # No snippet extractor due to code ray dependency
        "    <pre class=\"ruby\"><code>#{backtrace.compact}</code></pre>"
      end
    end
  end
end
