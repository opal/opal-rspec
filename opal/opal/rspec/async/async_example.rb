class ::RSpec::Core::Example
  def notify_async_exception(exception)
    @async_exceptions << exception
  end
  
  def notify_async_completed
    if pending?
      ::RSpec::Core::Pending.mark_fixed! self

      @async_exceptions << ::RSpec::Core::Pending::PendingExampleFixedError.new(
            'Expected example to fail since it is pending, but it passed.',
            [location])
    end
                
    if @async_exceptions.any?
      puts 'got an exception, noting it'
      # exception needs to be set before calling finish so results are correct
      # the first test to fail should be the one reported
      set_exception @async_exceptions.first
    end
    
    run_after_example

    @example_group_instance.instance_variables.each do |ivar|
      @example_group_instance.instance_variable_set(ivar, nil)
    end
    
    @example_group_instance = nil    
    result = finish(@reporter)
    puts "reporter finish result is #{result}"     
    ::RSpec.current_example = nil
    puts "----- example complete #{metadata[:description]} ------"
    @example_completed_promise.resolve result
  end
  
  def run(example_group_instance, reporter)
    puts "----- example begin #{metadata[:description]} ------"
    @example_completed_promise = Promise.new
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
      # TODO: Put around back in here
      run_before_example
      # Our wrapped block will execute with self == the group, not as the example, so we need to hold onto this for our promise resolve
      example_scope = self
      @async_exceptions = []            
      possible_example_promise = @example_group_instance.instance_exec(self, &@example_block)
      puts "possible_example_promise is a #{possible_example_promise}"
      # shortcut
      if possible_example_promise.is_a? Promise
        puts 'is promise'
        possible_example_promise.then do
          puts 'notifying ok'
          example_scope.notify_async_completed
        end.fail do |failure_reason|
          puts "failing #{failure_reason}"
          failure_reason ||= Exception.new 'Async promise failed for unspecified reason'
          failure_reason = Exception.new failure_reason unless failure_reason.kind_of?(Exception)
          example_scope.notify_async_exception failure_reason
          example_scope.notify_async_completed
        end
      else
        puts 'not a promise, resolving immediately'
        example_scope.notify_async_completed
      end
    end
    @example_completed_promise
  end
end
