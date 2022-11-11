# await: *await*

module ::RSpec
  module Core
    class ExampleGroup
      # @param duration [Integer, Float] time in seconds to wait
      def delay(duration, &block)
        `setTimeout(block, duration * 1000)`
        self
      end

      def delay_with_promise(duration, &block)
        result = PromiseV2.new
        delay(duration) { result.resolve }
        result.then(&block)
      end

      def self.run_await(reporter=RSpec::Core::NullReporter)
        # added awaits
        return if RSpec.world.wants_to_quit
        reporter.example_group_started(self)

        should_run_context_hooks = descendant_filtered_examples.any?
        begin
          RSpec.current_scope = :before_context_hook
          run_before_context_hooks_await(new('before(:context) hook')) if should_run_context_hooks
          result_for_this_group = run_examples_await(reporter)
          results_for_descendants = ordering_strategy.order(children).map_await { |child| child.run_await(reporter) }.all?
          result_for_this_group && results_for_descendants
        rescue Pending::SkipDeclaredInExample => ex
          for_filtered_examples(reporter) { |example| example.skip_with_exception(reporter, ex) }
          true
        rescue Support::AllExceptionsExceptOnesWeMustNotRescue => ex
          for_filtered_examples(reporter) { |example| example.fail_with_exception(reporter, ex) }
          RSpec.world.wants_to_quit = true if reporter.fail_fast_limit_met?
          false
        ensure
          RSpec.current_scope = :after_context_hook
          run_after_context_hooks_await(new('after(:context) hook')) if should_run_context_hooks
          reporter.example_group_finished(self)
        end
      end

      def self.run_examples_await(reporter)
        # added awaits
        ordering_strategy.order(filtered_examples).map_await do |example|
          next if RSpec.world.wants_to_quit
          instance = new(example.inspect_output)
          set_ivars(instance, before_context_ivars)
          succeeded = example.run_await(instance, reporter)
          if !succeeded && reporter.fail_fast_limit_met?
            RSpec.world.wants_to_quit = true
          end
          succeeded
        end.all?
      end

      # @private
      def self.run_before_context_hooks_await(example_group_instance)
        set_ivars(example_group_instance, superclass_before_context_ivars)

        @currently_executing_a_context_hook = true
        
        ContextHookMemoized::Before.isolate_for_context_hook_await(example_group_instance) do
          hooks.run_await(:before, :context, example_group_instance)
        end
      ensure
        store_before_context_ivars(example_group_instance)
        @currently_executing_a_context_hook = false
      end

      def self.run_after_context_hooks_await(example_group_instance)
        set_ivars(example_group_instance, before_context_ivars)

        @currently_executing_a_context_hook = true

        ContextHookMemoized::After.isolate_for_context_hook_await(example_group_instance) do
          hooks.run_await(:after, :context, example_group_instance)
        end
      ensure
        before_context_ivars.clear
        @currently_executing_a_context_hook = false
      end
    end
  end
end
