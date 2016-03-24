class ::RSpec::Core::Example
  def core_block_run
    example_promise = Promise.value(@example_group_instance.instance_exec(self, &@example_block))
    example_promise.then do |result|
      result
    end.rescue do |ex|
      ex ||= Exception.new 'Async promise failed for unspecified reason'
      ex = Exception.new ex unless ex.kind_of?(Exception)
      ex
    end
  end

  # TODO: Use subject! to create a before hook on the fly, might be cleaner than this
  # Might be a better way to do this, but then you end up with promises around the expectation handlers, which could get ugly
  def resolve_subject
    begin
      subj = example_group_instance.subject
      if subj.is_a? Promise
        return subj.then do |resolved_subject|
          # This is a private method, but we're using Opal
          example_group_instance.__memoized[:subject] = resolved_subject
        end
      end
    rescue Exception => _ # Can't use empty rescue in Opal 0.10 because it won't catch native JS exceptions (which aren't StandardError instances)
      # Exception occurred while checking the subject, might be that the example group had a described class, was not intending on using it as the subject,
      # and the initializer for that described class failed
    end
    Promise.value(true)
  end

  def run_after_example
    assign_generated_description if defined?(::RSpec::Matchers)
    hooks.run(:after, :example, self).then do
      verify_mocks
    end.ensure do
      @example_group_instance.teardown_mocks_for_rspec
    end
  end

  def run(example_group_instance, reporter)
    @example_group_instance = example_group_instance
    @reporter = reporter
    hooks.register_global_singleton_context_hooks(self, RSpec.configuration.hooks)
    RSpec.configuration.configure_example(self)
    RSpec.current_example = self
    start(reporter)
    Pending.mark_pending!(self, pending) if pending?

    Promise.value(true).then do
      Promise.value(true).then do
        if skipped?
          Pending.mark_pending! self, skip
        elsif !RSpec.configuration.dry_run?
          with_around_and_singleton_context_hooks do
            Promise.value(true).then do
              run_before_example.then do
                resolve_subject
              end.then do
                core_block_run
              end.then do
                if pending?
                  Pending.mark_fixed! self

                  raise Pending::PendingExampleFixedError,
                        'Expected example to fail since it is pending, but it passed.',
                        [location]
                end
              end
            end.rescue do |e|
              case e
              when Pending::SkipDeclaredInExample
                # no-op, required metadata has already been set by the `skip`
                # method.
              when AllExceptionsExcludingDangerousOnesOnRubiesThatAllowIt
                set_exception(e)
              else
                puts "Unexpected exception! #{e}"
                raise e
              end
            end.ensure do
              run_after_example
            end
          end
        end
      end.rescue do |e|
        case e
        when Support::AllExceptionsExceptOnesWeMustNotRescue
          set_exception(e)
        else
          puts "Unexpected exception! #{e}"
          raise e
        end
      end.ensure do
        @example_group_instance = nil # if you love something... let it go
      end
    end.then do
      finish(reporter)
    end.ensure do |result|
      execution_result.ensure_timing_set(clock)
      RSpec.current_example = nil
      # promise always/ensure do not behave exactly like ensure, need to be explicit about value being returned
      result
    end
  end
end
