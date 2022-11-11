# await: *await*

module RSpec
  module Core
    class Configuration
      def with_suite_hooks_await
        return yield if dry_run?

        begin
          RSpec.current_scope = :before_suite_hook
          run_suite_hooks("a `before(:suite)` hook", @before_suite_hooks)
          yield.await
        ensure
          RSpec.current_scope = :after_suite_hook
          run_suite_hooks("an `after(:suite)` hook", @after_suite_hooks)
          RSpec.current_scope = :suite
        end
      end

      def run_suite_hooks_await(hook_description, hooks)
        context = SuiteHookContext.new(hook_description, reporter)

        hooks.each do |hook|
          begin
            hook.run(context).await
          rescue Support::AllExceptionsExceptOnesWeMustNotRescue => ex
            context.set_exception(ex)

            # Do not run subsequent `before` hooks if one fails.
            # But for `after` hooks, we run them all so that all
            # cleanup bits get a chance to complete, minimizing the
            # chance that resources get left behind.
            break if hooks.equal?(@before_suite_hooks)
          end
        end
      end
    end
  end
end
