module Opal
  module RSpec
    module AsyncHelpers
      module ClassMethods
        def async(desc, *args, &block)
          options = ::RSpec::Core::Metadata.build_hash_from(args)
          Opal::RSpec::AsyncExample.register(self, desc, options, block)
        end
      end

      def self.included(base)
        base.extend ClassMethods
      end

      def async(&block)
        @example.continue_async(block)
      end

      alias run_async async

      def delay(duration, &block)
        `setTimeout(block, duration * 1000)`
        self
      end

      alias set_timeout delay
    end

    class AsyncRunner
      def initialize(runner, reporter, finish_block)
        @runner = runner
        @reporter = reporter
        @finish_block = finish_block
      end

      def run
        @examples = AsyncExample.examples.clone
        run_next_example
      end

      def run_next_example
        if @examples.empty?
          finish
        else
          run_example @examples.pop
        end
      end

      def run_example(example)
        example_group = example.example_group

        @reporter.example_group_started example_group
        instance = example_group.new

        example.run(instance, @reporter) do
          example_finished example
        end
      end

      def example_finished(example)
        @reporter.example_group_finished example.example_group
        run_next_example
      end

      # Called once all examples have finished. Just calls back to main
      # runner to inform it
      def finish
        @finish_block.call
      end
    end

    class AsyncExample < ::RSpec::Core::Example
      def self.register(*args)
        examples << new(*args)
      end

      def self.examples
        @examples ||= []
      end

      include AsyncHelpers

      def run(example_group_instance, reporter, &after_run_block)
        @example_group_instance = example_group_instance
        @reporter               = reporter
        @after_run_block        = after_run_block
        @finished               = false

        should_wait = true

        ::RSpec.current_example = self
        example_group_instance.instance_variable_set :@example, self

        start(reporter)

        begin
          run_before_each
          @example_group_instance.instance_exec(self, &@example_block)
        rescue Exception => e
          set_exception(e)
          should_wait = false
        end

        if should_wait
          delay options[:timeout] || 10 do
            next if finished?

            set_exception RuntimeError.new("timeout")
            async_example_finished
          end
        else
          async_example_finished
        end
      end

      def continue_async(block)
        return if finished?

        begin
          block.call
        rescue Exception => e
          set_exception(e)
        end

        async_example_finished
      end

      def finished?
        @finished
      end

      def async_example_finished
        @finished = true

        begin
          run_after_each
        rescue Exception => e
          set_exception(e)
        ensure
          @example_group_instance.instance_variables.each do |ivar|
            @example_group_instance.instance_variable_set(ivar, nil)
          end
          @example_group_instance = nil

          begin
            assign_generated_description
          rescue Exception => e
            set_exception(e, "while assigning the example description")
          end
        end

        finish(@reporter)
        ::RSpec.current_example = nil
        @after_run_block.call
      end
    end
  end
end
