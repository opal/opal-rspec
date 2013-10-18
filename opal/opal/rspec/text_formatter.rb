module OpalRSpec
  class TextFormatter
    attr_accessor :example_group
    attr_reader :duration, :examples, :output
    attr_reader :example_count, :pending_count, :failure_count
    attr_reader :failed_examples, :pending_examples

    def initialize(*args)
      @example_count = @pending_count = @failure_count = 0
      @examples = []
      @failed_examples = []
      @pending_examples = []
      @example_group = nil
    end

    def start(example_count)
      @example_count = example_count
    end

    def example_group_started(example_group)
      @example_group = example_group
    end

    def example_group_finished(example_group)
    end

    def example_started(example)
      examples << example
    end

    def example_passed(example)
    end

    def example_pending(example)
      @pending_examples << example
    end

    def example_failed(example)
      @failed_examples << example
    end

    def stop
    end

    def start_dump
    end

    def dump_failures
      return if failed_examples.empty?
      puts "\n"
      puts "Failures:"
      failed_examples.each_with_index do |example, index|
        puts "\n"
        dump_failure(example, index)
      end
    end

    def dump_failure(example, index)
      puts "#{short_padding}#{index.next}) #{example.full_description}"
      dump_failure_info(example)
    end

    def dump_failure_info(example)
      exception = example.execution_result[:exception]
      exception_class_name = exception.class.name.to_s
      puts "#{long_padding}#{exception_class_name}:"
      exception.message.to_s.split("\n").each { |line| puts "#{long_padding}  #{line}" }
    end

    def short_padding
      '  '
    end

    def long_padding
      '     '
    end

    def dump_summary(duration, example_count, failure_count, pending_count)
      @duration = duration
      @example_count = example_count
      @failure_count = failure_count
      @pending_count = pending_count

      puts "\nFinished\n"
      puts "#{example_count} examples, #{failure_count} failures (time taken: #{duration})"

      if failure_count == 0
        finish_with_code(0)
      else
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
  end
end

