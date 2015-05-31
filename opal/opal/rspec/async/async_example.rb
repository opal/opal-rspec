class Opal::RSpec::AsyncExample < ::RSpec::Core::Example  
  def run(example_group_instance, reporter)
    promise = Promise.new
    @example_group_instance = example_group_instance
    ::RSpec.current_example = self

    start(reporter)
    ::RSpec::Core::Pending.mark_pending!(self, pending) if pending?

    begin
      if skipped?
        ::RSpec::Core::Pending.mark_pending! self, skip
      elsif !::RSpec.configuration.dry_run?
        with_around_example_hooks do
          begin
            run_before_example
            example_scope = self        
            wrapped_block = lambda do |example|
              done = lambda do
                test_exception = @@async_exception != :do_not_throw ? @@async_exception : nil
                if test_exception
                  # exception needs to be set before calling finish
                  example_scope.set_exception test_exception
                  # reset
                  @@async_exception = :do_not_throw
                end
                example_scope.finish(reporter)
                promise.resolve test_exception == nil
              end
              @@async_exception = :do_not_throw
              self.instance_exec(done, example, &example_scope.instance_variable_get(:@example_block))
            end
            
            @example_group_instance.instance_exec(self, &wrapped_block)

            if pending?
              ::RSpec::Core::Pending.mark_fixed! self

              raise ::RSpec::Core::Pending::PendingExampleFixedError,
                    'Expected example to fail since it is pending, but it passed.',
                    [location]
            end
          rescue ::RSpec::Core::Pending::SkipDeclaredInExample
            # no-op, required metadata has already been set by the `skip`
            # method.
          rescue Exception => e
            set_exception(e)
          ensure
            run_after_example
          end
        end
      end
    rescue Exception => e
      set_exception(e)
    ensure
      @example_group_instance.instance_variables.each do |ivar|
        @example_group_instance.instance_variable_set(ivar, nil)
      end
      @example_group_instance = nil
    end
  ensure
    ::RSpec.current_example = nil
  end
end
