module Opal
  module RSpec
    class TextFormatter < ::RSpec::Core::Formatters::BaseFormatter

      ::RSpec::Core::Formatters.register self,
                          :message, :dump_summary, :dump_failures, :dump_pending, :seed

      def dump_failures
        if failed_examples.empty?
          puts "\nFinished"
        else
          puts "\nFailures:"
          failed_examples.each_with_index do |example, index|
            puts "\n"
            dump_failure(example, index)
          end
        end
      end

      def dump_failure(example, index)
        puts "#{short_padding}#{index.next}) #{example.full_description}"
        dump_failure_info(example)
      end

      def dump_failure_info(example)
        exception = example.execution_result[:exception]
        exception_class_name = exception.class.name.to_s
        red "#{long_padding}#{exception_class_name}:"
        exception.message.to_s.split("\n").each { |line| red "#{long_padding}  #{line}" }
      end

      def dump_summary(duration, example_count, failure_count, pending_count)
        @duration = duration
        @example_count = example_count
        @failure_count = failure_count
        @pending_count = pending_count

        msg = "\n#{example_count} examples, #{failure_count} failures (time taken: #{duration})"

        if failure_count == 0
          green msg
          finish_with_code(0)
        else
          red msg
          finish_with_code(1)
        end
      end

      def finish_with_code(code)
        %x{
          if (typeof(phantom) !== "undefined") {
            phantom.exit(code);
          }
          else {
            Opal.global.OPAL_SPEC_CODE = code;
          }
        }
      end

      def green(str)
        `console.log('\033[32m' + str + '\033[0m')`
      end

      def red(str)
        `console.log('\033[31m' + str + '\033[0m')`
      end

      def short_padding
        '  '
      end

      def long_padding
        '     '
      end
    end
  end
end
