require 'promise'

class ::RSpec::Core::ExampleGroup
  # @param duration [Integer, Float] time in seconds to wait
  def delay(duration, &block)
    `setTimeout(block, duration * 1000)`
    self
  end
  
  def self.async(*all_args, &block)
    desc, *args = *all_args

    options = Metadata.build_hash_from(args)
    options.update(:skip => RSpec::Core::Pending::NOT_YET_IMPLEMENTED) unless block

    examples << Opal::RSpec::AsyncExample.new(self, desc, options, block)
    examples.last
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
    result_promise_for_this_group.then do |this_group_result|
      # TODO: Need to run descendants here
      run_after_context_hooks(new)
      before_context_ivars.clear
      reporter.example_group_finished(self)
      result_promise.resolve this_group_result
    end
    ordering_strategy.order(children).each do |child|
      puts "child is #{child}"
    end
    result_promise
      # begin
    #       run_before_context_hooks(new)
#       result_for_this_group = run_examples(reporter)
#       results_for_descendants = ordering_strategy.order(children).map { |child| child.run(reporter) }.all?
#       result_for_this_group && results_for_descendants
#     rescue Pending::SkipDeclaredInExample => ex
#       for_filtered_examples(reporter) { |example| example.skip_with_exception(reporter, ex) }
#     rescue Exception => ex
#       RSpec.world.wants_to_quit = true if fail_fast?
#       for_filtered_examples(reporter) { |example| example.fail_with_exception(reporter, ex) }
#     ensure
#       run_after_context_hooks(new)
#       before_context_ivars.clear
#       reporter.example_group_finished(self)
#     end
  end
  
  # Promise oriented version
  def self.run_examples(reporter)   
    example_promise = lambda do |example|
      instance = new
      set_ivars(instance, before_context_ivars)
      promise_or_result = example.run(instance, reporter)
      promise = Promise.new
      if promise_or_result.is_a? Promise
        puts "got back a promise from example #{example}"
        promise_or_result.then do |result|
          puts "sending back result #{result} for example #{example}"
          promise.resolve result
        end
      else
        promise.resolve promise_or_result
      end
      promise
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
