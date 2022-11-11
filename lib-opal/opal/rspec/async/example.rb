# await: *await*

module RSpec
  module Core
    class Example
      def run_await(example_group_instance, reporter)
        # added awaits
        @example_group_instance = example_group_instance
        @reporter = reporter
        RSpec.configuration.configure_example(self, hooks)
        RSpec.current_example = self

        start(reporter)
        Pending.mark_pending!(self, pending) if pending?

        begin
          if skipped?
            Pending.mark_pending! self, skip
          elsif !RSpec.configuration.dry_run?
            with_around_and_singleton_context_hooks_await do
              begin
                run_before_example_await
                RSpec.current_scope = :example
                @example_group_instance.instance_exec_await(self, &@example_block)

                if pending?
                  Pending.mark_fixed! self

                  raise Pending::PendingExampleFixedError,
                        'Expected example to fail since it is pending, but it passed.',
                        [location]
                end
              rescue Pending::SkipDeclaredInExample => _
                # The "=> _" is normally useless but on JRuby it is a workaround
                # for a bug that prevents us from getting backtraces:
                # https://github.com/jruby/jruby/issues/4467
                #
                # no-op, required metadata has already been set by the `skip`
                # method.
              rescue AllExceptionsExcludingDangerousOnesOnRubiesThatAllowIt => e
                set_exception(e)
              ensure
                RSpec.current_scope = :after_example_hook
                run_after_example_await
              end
            end
          end
        rescue Support::AllExceptionsExceptOnesWeMustNotRescue => e
          set_exception(e)
        ensure
          @example_group_instance = nil # if you love something... let it go
        end

        finish(reporter)
      ensure
        execution_result.ensure_timing_set(clock)
        RSpec.current_example = nil
      end

      def run_before_example_await
        # added awaits
        @example_group_instance.setup_mocks_for_rspec
        hooks.run_await(:before, :example, self)
      end

      def run_after_example_await
        # added awaits
        assign_generated_description if defined?(::RSpec::Matchers)
        hooks.run_await(:after, :example, self)
        verify_mocks
      ensure
        @example_group_instance.teardown_mocks_for_rspec
      end

      def with_around_and_singleton_context_hooks_await
        singleton_context_hooks_host = example_group_instance.singleton_class
        singleton_context_hooks_host.run_before_context_hooks_await(example_group_instance)
        with_around_example_hooks_await { yield.await }
      ensure
        singleton_context_hooks_host.run_after_context_hooks_await(example_group_instance)
      end

      def with_around_example_hooks_await
        RSpec.current_scope = :before_example_hook
        hooks.run_await(:around, :example, self) { yield.await }
      rescue Support::AllExceptionsExceptOnesWeMustNotRescue => e
        set_exception(e)
      end

      def instance_exec_await(*args, &block)
        @example_group_instance.instance_exec_await(*args, &block)
      end

      class Procsy
        alias run_await run
      end
    end
  end
end
