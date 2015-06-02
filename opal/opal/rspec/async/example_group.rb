require 'promise'

class ::RSpec::Core::ExampleGroup
  # @param duration [Integer, Float] time in seconds to wait
  def delay(duration, &block)
    `setTimeout(block, duration * 1000)`
    self
  end  
  
  def delay_with_promise(duration, &block)
    result = Promise.new
    delay duration, lambda { result.resolve }
    result.then do
      begin
        self.instance_eval(&block)
      rescue StandardError => e
        Promise.new.reject e
      end
    end
  end

  def self.get_promise_based_on_completion_of(promise_or_result)
    promise = Promise.new
    if promise_or_result.is_a? Promise
      promise_or_result.then do |result|
        promise.resolve result
      end
    else
      promise.resolve promise_or_result
    end
    promise
  end

  # Promise oriented version
  def self.run(reporter)
    if RSpec.world.wants_to_quit
      RSpec.world.clear_remaining_example_groups if top_level?
      return
    end
    
    reporter.example_group_started(self)    
    run_before_context_hooks(new)
    result_promise = Promise.new        
    result_promise_for_this_group = run_examples(reporter)
    result_promise_for_this_group.then do |result_for_this_group|
      results_for_descendants = []
      latest_descendant = ordering_strategy.order(children).inject(Promise.new.resolve(true)) do |previous_promise, next_descendant|
        previous_promise.then do |result|
          results_for_descendants << result
          promise_or_result = next_descendant.run reporter
          get_promise_based_on_completion_of promise_or_result
        end
      end
      latest_descendant.then do |result|
        results_for_descendants << result
        combined_result = result_for_this_group && results_for_descendants.all?
        run_after_context_hooks(new)
        before_context_ivars.clear
        reporter.example_group_finished(self)
        result_promise.resolve combined_result
      end
      # TODO: Incorporate for_filtered_examples(reporter) { |example| example.skip_with_exception(reporter, ex) } like sync example_group does
      # TODO: Incorporate fail fast stuff      
    end
    result_promise     
  end
  
  # Promise oriented version
  def self.run_examples(reporter)   
    example_promise = lambda do |example|
      instance = new
      set_ivars(instance, before_context_ivars)
      promise_or_result = example.run(instance, reporter)
      get_promise_based_on_completion_of promise_or_result
    end  
    
    results = []
    latest_promise = ordering_strategy.order(filtered_examples).inject(Promise.new.resolve(true)) do |previous_promise, next_example|
      previous_promise.then do |result|
        results << result
        example_promise[next_example]
      end
    end
    
    result_promise = Promise.new
    latest_promise.then do |result|
      results << result
      result_promise.resolve results.all?  
    end
    
    result_promise   
  end
end
