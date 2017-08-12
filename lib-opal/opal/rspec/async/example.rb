require 'js'

class ::RSpec::Core::Example
  # WAS:
  #   def run_after_example
  #     @example_group_class.hooks.run(:after, :example, self)
  #     verify_mocks
  #     assign_generated_description if RSpec.configuration.expecting_with_rspec?
  #   rescue Exception => e
  #     set_exception(e, "in an `after(:example)` hook")
  #   ensure
  #     @example_group_instance.teardown_mocks_for_rspec
  #   end
  # NOW:
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

    # WAS:
    #   …
    #     begin
    #       if skipped?
    #         Pending.mark_pending! self, skip
    #       elsif !RSpec.configuration.dry_run?
    #         with_around_example_hooks do
    #           begin
    #             run_before_example
    #             @example_group_instance.instance_exec(self, &@example_block)
    #
    #             if pending?
    #               Pending.mark_fixed! self
    #
    #               raise Pending::PendingExampleFixedError,
    #                     'Expected example to fail since it is pending, but it passed.',
    #                     [location]
    #             end
    #           rescue Pending::SkipDeclaredInExample
    #             # no-op, required metadata has already been set by the `skip`
    #             # method.
    #           rescue Exception => e
    #             set_exception(e)
    #           ensure
    #             run_after_example
    #           end
    #         end
    #       end
    #     rescue Exception => e
    #       set_exception(e)
    #     ensure
    #       @example_group_instance.instance_variables.each do |ivar|
    #         @example_group_instance.instance_variable_set(ivar, nil)
    #       end
    #       @example_group_instance = nil
    #     end
    #
    #     finish(reporter)
    #   ensure
    #     RSpec.current_example = nil
    Promise.value(true).then do
      Promise.value(true).then do
        if skipped?
          Pending.mark_pending! self, skip
        elsif !RSpec.configuration.dry_run?
          with_around_example_hooks do
            # WAS:
            #   with_around_example_hooks do
            #     begin
            #       run_before_example
            #       @example_group_instance.instance_exec(self, &@example_block)
            #
            #       if pending?
            #         Pending.mark_fixed! self
            #
            #         raise Pending::PendingExampleFixedError,
            #               'Expected example to fail since it is pending, but it passed.',
            #               [location]
            #       end
            #     rescue Pending::SkipDeclaredInExample
            #       # no-op, required metadata has already been set by the `skip`
            #       # method.
            #     rescue Exception => e
            #       set_exception(e)
            #     ensure
            #       run_after_example
            #     end
            #   end
            # NOW:
            Promise.value(true).then do
              run_before_example
              .then do
                # TODO: Use subject! to create a before hook on the fly, might be cleaner than this
                # Might be a better way to do this, but then you end up with promises around the expectation handlers, which could get ugly
                begin
                  subj = example_group_instance.subject
                  if subj.is_a? Promise
                    return subj.then do |resolved_subject|
                      # This is a private method, but we're using Opal
                      example_group_instance.__memoized[:subject] = resolved_subject
                    end
                  end
                rescue StandardError, JS::Error
                  # Exception occurred while checking the subject, might be that the example
                  # group had a described class, was not intending on using it as the subject,
                  # and the initializer for that described class failed
                end
                Promise.value(true)
              end
              .then do
                # WAS:
                #   @example_group_instance.instance_exec(self, &@example_block)
                # NOW:
                Promise.value(@example_group_instance.instance_exec(self, &@example_block)).then do |result|
                  result
                end.rescue do |ex|
                  case ex
                  when nil then Exception.new 'Async promise failed for unspecified reason'
                  when Exception then ex
                  else Exception.new(ex)
                  end
                end
              end
              .then do
                # ORIGINAL:
                if pending?
                  Pending.mark_fixed! self

                  raise Pending::PendingExampleFixedError,
                        'Expected example to fail since it is pending, but it passed.',
                        [location]
                end
              end
            end.rescue do |e|
              # WAS:
              #   rescue Pending::SkipDeclaredInExample
              #     # no-op, required metadata has already been set by the `skip`
              #     # method.
              #   rescue Exception => e
              #     set_exception(e)
              #   ensure
              #     run_after_example
              #   end
              # NOW:
              case e
              when Pending::SkipDeclaredInExample
                # no-op, required metadata has already been set by the `skip`
                # method.
              when Exception
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
