class ::RSpec::Core::Example  
  def notify_async_completed(reporter, exception=nil)
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
      
      result = finish(reporter)     
      puts "----- example complete #{metadata[:description]} with result #{result} ------"
      return result
    end
    ensure
      ::RSpec.current_example = nil
  end
  
  def core_block_run(result_promise, reporter)
    possible_example_promise = @example_group_instance.instance_exec(self, &@example_block)    
    puts "possible_example_promise for #{metadata[:description]} is a #{possible_example_promise}"
    synchronous_example = !possible_example_promise.is_a?(Promise)
    puts "synchronous example!" if synchronous_example
    example_promise = synchronous_example ? Promise.value(possible_example_promise) : possible_example_promise
    example_promise.then do |result|
      puts 'notifying completed'
      result = notify_async_completed reporter
      result_promise.resolve result
    end.rescue do |ex|
      ex ||= Exception.new 'Async promise failed for unspecified reason'
      ex = Exception.new ex unless ex.kind_of?(Exception)          
      puts "notifying example exception #{ex}"
      result = notify_async_completed reporter, ex
      result_promise.resolve result
    end
  end
  
  def run(example_group_instance, reporter)
    puts "----- example begin #{metadata[:description]} ------"    
    @example_group_instance = example_group_instance
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
        result_promise = Promise.new

        if example_group_instance.respond_to? :subject and example_group_instance.subject.is_a?(Promise)
          example_group_instance.subject.then do |resolved_subject|
            # This is a private method, but we're using Opal
            example_group_instance.__memoized[:subject] = resolved_subject
            puts 'running core_block_run'
            # the parent rescue won't catch exceptions because we're in a then!
            begin
              core_block_run result_promise, reporter
            rescue Exception => ex
              puts "Synchronous exception with async subject detected! #{ex}"
              # We'll never make it to the result_promise.resolve in core_block_run, need to do it here
              result_promise.resolve notify_async_completed(reporter, ex)
            end
          end
        else
          core_block_run result_promise, reporter
        end
        # Needs to be returned
        result_promise
      rescue Exception => ex
        puts "Synchronous exception detected! #{ex}"
        Promise.value(notify_async_completed(reporter, ex))
      end
    end
  end
end
