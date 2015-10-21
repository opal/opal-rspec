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
    rescue
      # Exception occurred while checking the subject, might be that the example group had a described class, was not intending on using it as the subject,
      # and the initializer for that described class failed
    end
    Promise.value
  end

  def run_after_example
    @example_group_class.hooks.run(:after, :example, self).then do
      verify_mocks
      assign_generated_description if RSpec.configuration.expecting_with_rspec?
    end.rescue do |e|
      set_exception(e, "in an `after(:example)` hook")
    end.ensure do
      @example_group_instance.teardown_mocks_for_rspec
    end
  end

  def run(example_group_instance, reporter)
    @example_group_instance = example_group_instance
    RSpec.current_example = self

    start(reporter)
    Pending.mark_pending!(self, pending) if pending?

    Promise.value.then do
      Promise.value.then do
        if skipped?
          Pending.mark_pending! self, skip
        elsif !RSpec.configuration.dry_run?
          with_around_example_hooks do
            Promise.value.then do
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
              # no-op, required metadata has already been set by the `skip`
              # method.
              unless e.is_a? Pending::SkipDeclaredInExample
                set_exception(e)
              end
            end.ensure do
              run_after_example
            end
          end
        end
      end.rescue do |e|
        set_exception(e)
      end.ensure do
        @example_group_instance.instance_variables.each do |ivar|
          @example_group_instance.instance_variable_set(ivar, nil)
        end
        @example_group_instance = nil
      end
    end.then do
      finish(reporter)
    end.ensure do |result|
      RSpec.current_example = nil
      # promise always/ensure do not behave exactly like ensure, need to be explicit about value being returned
      result
    end
  end
end
