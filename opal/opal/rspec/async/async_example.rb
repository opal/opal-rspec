class ::RSpec::Core::Example
  def with_around_example_hooks(&block)
    if around_example_hooks.empty?
      yield
    else
      # Async examples will return a promise for the around hook to use after calling example.run
      # Sync examples don't. Rather than monkey patch that method, which is more key to RSpec, monkey patching this, which is a smaller method
      use_block = if self.is_a? Opal::RSpec::AsyncExample
        block
      else
        lambda do
          block.call          
          Promise.new.resolve
        end
      end
      @example_group_class.hooks.run(:around, :example, self, Procsy.new(self, &use_block))
    end
  rescue Exception => e
    set_exception(e, "in an `around(:example)` hook")
  end
end


class Opal::RSpec::AsyncExample < ::RSpec::Core::Example  
  def notify_async_completed
    return if @async_completed
    if pending?
      ::RSpec::Core::Pending.mark_fixed! self

      @@async_exceptions << ::RSpec::Core::Pending::PendingExampleFixedError.new(
            'Expected example to fail since it is pending, but it passed.',
            [location])
    end
                
    if @@async_exceptions.any?
      # exception needs to be set before calling finish so results are correct
      # the first test to fail should be the one reported
      set_exception @@async_exceptions.first
    end
    
    run_after_example

    @example_group_instance.instance_variables.each do |ivar|
      @example_group_instance.instance_variable_set(ivar, nil)
    end
    
    @example_group_instance = nil
    
    result = finish(@reporter)              
    ::RSpec.current_example = nil
    
    @async_completed = true
    
    # A synchronous test might follow
    @@async_exceptions = nil
    
    unless around_example_hooks.empty?
      around_promise_completed = Promise.new
      around_promise_completed.then { @promise.resolve result }
      @around_promise_begin.resolve [result, around_promise_completed]
    else
      @around_promise_begin.resolve result
      @promise.resolve result
    end
    # nil is important, otherwise a done.call might be interpreted as a promise by the shortcut code below
    nil
  end
  
  def run(example_group_instance, reporter)
    @promise = Promise.new
    @example_group_instance = example_group_instance
    # It may not be ideal for reporter to be an instance variable, but it makes it a lot easier to separate this out into methods
    @reporter = reporter
    ::RSpec.current_example = self

    start(reporter)
    ::RSpec::Core::Pending.mark_pending!(self, pending) if pending?    

    if skipped?
      ::RSpec::Core::Pending.mark_pending! self, skip
      result = finish(reporter)              
      ::RSpec.current_example = nil
      @promise.resolve result
    elsif !::RSpec.configuration.dry_run?
      with_around_example_hooks do
        @around_promise_begin = Promise.new
        run_before_example
        # Our wrapped block will execute with self == the group, not as the example, so we need to hold onto this for our promise resolve
        example_scope = self
        @async_completed = false
        wrapped_block = lambda do |example|          
          done = lambda do
            example_scope.notify_async_completed
          end
          @@async_exceptions = []
          result = self.instance_exec(done, example, &example_scope.instance_variable_get(:@example_block))
          # shortcut
          if result.is_a? Promise
            result.then do
              example_scope.notify_async_completed
            end.fail do |failure_reason|
              failure_reason ||= Exception.new 'Async promise failed for unspecified reason'
              failure_reason = Exception.new failure_reason unless failure_reason.kind_of?(Exception)
              @@async_exceptions << failure_reason
              example_scope.notify_async_completed
            end
          end
        end
        
        @example_group_instance.instance_exec(self, &wrapped_block)
        # Around block needs this returned
        @around_promise_begin        
      end
    end
    @promise
  end
end
