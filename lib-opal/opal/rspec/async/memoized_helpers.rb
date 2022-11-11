module RSpec
  module Core
    # This module is included in {ExampleGroup}, making the methods
    # available to be called from within example blocks.
    #
    # @see ClassMethods
    module MemoizedHelpers
      class ContextHookMemoized
        def self.isolate_for_context_hook_await(example_group_instance)
          exploding_memoized = self

          example_group_instance.instance_exec_await do
            @__memoized = exploding_memoized

            begin
              yield.await
            ensure
              # This is doing a reset instead of just isolating for context hook.
              # Really, this should set the old @__memoized back into place.
              #
              # Caller is the before and after context hooks
              # which are both called from self.run
              # I didn't look at why it made tests fail, maybe an object was getting reused in RSpec tests,
              # if so, then that probably already works, and its the tests that are wrong.
              __init_memoized
            end
          end
        end
      end
    end
  end
end
