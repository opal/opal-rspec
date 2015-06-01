class Opal::RSpec::AsyncExample < ::RSpec::Core::Example 
  def notify_async_completed
    @done.call
  end
  
  def run(example_group_instance, reporter)
    promise = Promise.new
    @example_group_instance = example_group_instance
    ::RSpec.current_example = self

    start(reporter)
    ::RSpec::Core::Pending.mark_pending!(self, pending) if pending?    

    if skipped?
      ::RSpec::Core::Pending.mark_pending! self, skip
      result = finish(reporter)              
      ::RSpec.current_example = nil
      promise.resolve result
    elsif !::RSpec.configuration.dry_run?
      # TODO: around example needs to be async
      with_around_example_hooks do
        around_promise_begin = Promise.new
        run_before_example
        # Our wrapped block will execute with self == the group, not as the example, so we need to hold onto this for our promise resolve
        example_scope = self
        set_done_block = lambda {|executing_block| @done = executing_block}
        @done_completed = false
        is_done_completed = lambda { @done_completed }
        set_done_completed = lambda { @done_completed = true }
        wrapped_block = lambda do |example|          
          done = lambda do
            next if is_done_completed.call
            if example_scope.pending?
              ::RSpec::Core::Pending.mark_fixed! example_scope

              @@async_exceptions << ::RSpec::Core::Pending::PendingExampleFixedError.new(
                    'Expected example to fail since it is pending, but it passed.',
                    [example_scope.location])
            end            
            if @@async_exceptions.any?
              # exception needs to be set before calling finish so results are correct
              # the first test to fail should be the one reported
              example_scope.set_exception @@async_exceptions.first
            end
            example_scope.run_after_example
            # Using run method parameter here since self != the example (see above)
            example_group_instance.instance_variables.each do |ivar|
              example_group_instance.instance_variable_set(ivar, nil)
            end
            example_scope.instance_variable_set(:@example_group_instance, nil)
            result = example_scope.finish(reporter)              
            ::RSpec.current_example = nil
            set_done_completed.call
            unless example_scope.around_example_hooks.empty?
              around_promise_completed = Promise.new
              around_promise_completed.then { promise.resolve result }
              around_promise_begin.resolve [result, around_promise_completed]
            else
              around_promise_begin.resolve result
              promise.resolve result
            end            
          end
          set_done_block[done]
          @@async_exceptions = []
          self.instance_exec(done, example, &example_scope.instance_variable_get(:@example_block))
          # Around block needs this returned
          around_promise_begin
        end
        
        @example_group_instance.instance_exec(self, &wrapped_block)
      end
    end
    promise
  end
end
