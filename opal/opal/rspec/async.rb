module Opal
  module RSpec
    module AsyncHelpers
      module ClassMethods
        def async(desc, *args, &block)
          options = ::RSpec::Core::Metadata.build_hash_from(args)
          Opal::RSpec::AsyncExample.new(self, desc, options, block)
        end
      end

      def self.included(base)
        base.extend ClassMethods
      end

      # @param duration [Integer, Float] time in seconds to wait
      def delay(duration, &block)
        `setTimeout(block, duration * 1000)`
        self
      end
    end    

    # An {AsyncExample} is a subclass of regular example instances which adds
    # support for running an example, and waiting for a non-sync outcome. All
    # async examples in a set of spec files will get registered through
    # {AsyncExample.register}, and added to the {AsyncExample.examples} array
    # ready for the runner to run.
    #
    # You will not need to create new instances of this class directly, and
    # should instead use {AsyncHelpers} to create async examples.
    class AsyncExample < ::RSpec::Core::Example
      include AsyncHelpers

      def run(example_group_instance, reporter)
        @example_group_instance = example_group_instance
        RSpec.current_example = self

        start(reporter)
        Pending.mark_pending!(self, pending) if pending?

        begin
          if skipped?
            Pending.mark_pending! self, skip
          elsif !RSpec.configuration.dry_run?
            with_around_example_hooks do
              begin
                run_before_example
                @example_group_instance.instance_exec(self, &@example_block)

                if pending?
                  Pending.mark_fixed! self

                  raise Pending::PendingExampleFixedError,
                        'Expected example to fail since it is pending, but it passed.',
                        [location]
                end
              rescue Pending::SkipDeclaredInExample
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

        finish(reporter)
      ensure
        RSpec.current_example = nil
      end
    end
  end
end
