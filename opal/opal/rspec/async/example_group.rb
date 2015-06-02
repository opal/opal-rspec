require 'promise'

class ::RSpec::Core::ExampleGroup
  # @param duration [Integer, Float] time in seconds to wait
  def delay(duration, &block)
    `setTimeout(block, duration * 1000)`
    self
  end  
  
  def delay_with_promise(duration, &block)
    result = Promise.new
    delay(duration) { 
      puts 'timer telling inner promise to resolve'
      result.resolve
    }
    result.then do
      puts 'timer triggered, eval block'
      begin
        self.instance_eval(&block)
      rescue StandardError => e
        puts "delay block failed #{e}"
        Promise.new.reject e
      end
    end
  end  

  def self.process_descendants(our_examples_result, reporter)
    descendants = ordering_strategy.order(children)
    if descendants.empty?
      puts "example_group.run - #{metadata[:description]} - no descendants, this group is complete, our examples result is #{our_examples_result}"
      return Promise.value our_examples_result
    end
    
    results_for_descendants = []
    # Can use true for this because we're AND'ing everything anyways
    seed = Promise.value(true)
    latest_descendant = descendants.inject(seed) do |previous_promise, next_descendant|
      previous_promise.then do |result|
        results_for_descendants << result
        p = next_descendant.run reporter
        puts "example_group.run - got back #{p} from descendant.run"
        p
      end
    end
    latest_descendant.then do |result|
      results_for_descendants << result
      combined_result = our_examples_result && results_for_descendants.all?      
      combined_result
    end    
  end

  # Promise oriented version
  def self.run(reporter)
    if RSpec.world.wants_to_quit
      RSpec.world.clear_remaining_example_groups if top_level?
      return
    end
    
    reporter.example_group_started(self)    
    run_before_context_hooks(new)

    puts "example_group.run - #{metadata[:description]} - starting run_examples"
    our_examples_promise = run_examples(reporter)
    puts "example_group.run - #{metadata[:description]} - got back run_examples promise of #{our_examples_promise}"
    ensure_stuff = lambda do
      run_after_context_hooks(new)
      before_context_ivars.clear
      reporter.example_group_finished(self)
    end
    our_examples_promise.then do |our_examples_result|
      process_descendants(our_examples_result, reporter).then do
        ensure_stuff.call
      end
    end.fail do |ex|
      puts "--FAILURE WITH EXCEPTION-- #{ex}"
      ex ||= Exception.new 'Async promise failed for unspecified reason'
      ex = Exception.new ex unless ex.kind_of?(Exception)
      result = if ex.is_a? Pending::SkipDeclaredInExample
        puts 'got skip'
        for_filtered_examples(reporter) { |example| example.skip_with_exception(reporter, ex) }        
      else
        RSpec.world.wants_to_quit = true if fail_fast?
        for_filtered_examples(reporter) { |example| example.fail_with_exception(reporter, ex) }
      end
      ensure_stuff.call
      puts "example_group.run - #{metadata[:description]} - returning #{result}"
      result
    end
  end
  
  # Promise oriented version
  def self.run_examples(reporter)   
    examples = ordering_strategy.order(filtered_examples)
    if examples.empty?
      puts "example_group.run_examples - #{metadata[:description]} - no examples, returning now"
      return Promise.value true
    end

    example_promise = lambda do |example|
      instance = new
      set_ivars(instance, before_context_ivars)
      # Always returns a promise since we modified the Example class
      p = example.run(instance, reporter)
      puts "example_group.run_examples - #{metadata[:description]} - got back #{p} from example.run"
      p
    end  
    
    results = []
    # Can use true for this because we're AND'ing everything anyways
    seed = Promise.value true
    puts "example_group.run_examples - #{metadata[:description]} - seed promise is #{seed}"
    latest_promise = examples.inject(seed) do |previous_promise, next_example|
      puts "example_group.run_examples - #{metadata[:description]} - inject loop - next example to QUEUE is #{next_example.metadata[:description]}, previous promise is #{previous_promise}"
      p2 = previous_promise.then do |succeeded|
        RSpec.world.wants_to_quit = true if fail_fast? && !succeeded
        puts "example_group.run_examples - #{metadata[:description]} - previous promise #{previous_promise} completed, now running next example (#{next_example.metadata[:description]})"
        results << succeeded
        example_promise[next_example]
      end
      puts "example_group.run_examples - #{metadata[:description]} - wrapped promise is #{p2}"
      p2
    end    

    puts "example_group.run_examples #{metadata[:description]} - last promise we are waiting on is #{latest_promise}"
    latest_promise.then do |succeeded|
      RSpec.world.wants_to_quit = true if fail_fast? && !succeeded
      puts "example_group.run_examples, #{metadata[:description]} - final example promise is #{latest_promise}, result was #{succeeded}"
      results << succeeded
      results.all?
    end
  end
end
