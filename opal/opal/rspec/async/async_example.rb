class ::RSpec::Core::Example  
  def notify_async_completed(exception)
    puts "notify_async_completed called with exception #{exception}"
    begin
      begin
        if exception
          unless exception.is_a? Pending::SkipDeclaredInExample
            puts 'got an exception, noting it'
            # exception needs to be set before calling finish so results are correct
            # the first test to fail should be the one reported
            set_exception exception
          end            
        else
          if pending?
            puts 'found pending example that did not fail!!!'
            ::RSpec::Core::Pending.mark_fixed! self

            set_exception ::RSpec::Core::Pending::PendingExampleFixedError.new(
                  'Expected example to fail since it is pending, but it passed.',
                  [location])
          end        
        end
      ensure
        run_after_example        
      end
    rescue Exception => e
      set_exception e
    ensure
      @example_group_instance.instance_variables.each do |ivar|
        @example_group_instance.instance_variable_set(ivar, nil)
      end  
      @example_group_instance = nil
      
      result = finish(@reporter)     
      puts "----- example complete #{metadata[:description]} with result #{result} ------"
      return result
    end
    ensure
      ::RSpec.current_example = nil
  end
  
  def run(example_group_instance, reporter)
    puts "----- example begin #{metadata[:description]} ------"    
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
      return Promise.value result
    elsif !::RSpec.configuration.dry_run?
      # TODO: Put around back in here      
      begin
        run_before_example
        # Not chaining to keep exceptions from propagating
        @result_promise = Promise.new
        possible_example_promise = @example_group_instance.instance_exec(self, &@example_block)
        puts "possible_example_promise is a #{possible_example_promise}"
        synchronous_example = !possible_example_promise.is_a?(Promise)
        puts "synchronous example!" if synchronous_example
        example_promise = synchronous_example ? Promise.value(possible_example_promise) : possible_example_promise
        example_promise.then do |result|
          puts 'notifying completed'
          result = notify_async_completed nil
          @result_promise.resolve result
        end.rescue do |ex|
          puts "notifying example exception #{ex}"
          result = notify_async_completed ex
          @result_promise.resolve result
        end
        # Needs to be returned
        @result_promise
      rescue Exception => ex
        puts "Synchronous exception detected! #{ex}"
        Promise.value(notify_async_completed(ex))
      end
    end
  end
end
