require_relative 'document_io'
require_relative 'html_printer'

module Opal
  module RSpec
    class BrowserFormatter < ::RSpec::Core::Formatters::HtmlFormatter
      ::RSpec::Core::Formatters.register self, :start, :example_group_started, :start_dump,
                                         :example_started, :example_passed, :example_failed,
                                         :example_pending, :dump_summary

      def initialize(output)
        super DocumentIO.new
        @printer = Opal::RSpec::HtmlPrinter.new(@output)
      end

      def extra_failure_content(failure)
        backtrace = failure.exception.backtrace.map { |line| ::RSpec.configuration.backtrace_formatter.backtrace_line(line) }
        # No snippet extractor due to code ray dependency
        "    <pre class=\"ruby\"><code>#{backtrace.compact}</code></pre>"
      end
    end
  end
end
