require 'promise'

class ::RSpec::Core::ExampleGroup
  # @param duration [Integer, Float] time in seconds to wait
  def delay(duration, &block)
    `setTimeout(block, duration * 1000)`
    self
  end

  def delay_with_promise(duration, &block)
    result = Promise.new
    delay(duration) { result.resolve }
    result.then &block
  end

  def self.process_descendants(our_examples_result, reporter)
    descendants = ordering_strategy.order(children)
    puts 'no desc!' if descendants.empty?
    return Promise.value(our_examples_result) if descendants.empty?

    results_for_descendants = []
    # Can use true for this because we're AND'ing everything anyways
    seed = Promise.value(true)
    latest_descendant = descendants.inject(seed) do |previous_promise, next_descendant|
      previous_promise.then do |result|
        results_for_descendants << result
        puts "running descendant #{next_descendant}"
        next_descendant.run reporter
      end
    end
    latest_descendant.then do |result|
      results_for_descendants << result
      our_examples_result && results_for_descendants.all?
    end
  end

  # Promise oriented version
  def self.run(reporter)
    # new
    return if RSpec.world.wants_to_quit
    reporter.example_group_started(self)

    should_run_context_hooks = descendant_filtered_examples.any?
    Promise.value(true).then do
      puts 'example group run before context'
      run_before_context_hooks(new('before(:context) hook')) if should_run_context_hooks
    end.then do
      puts 'run examples'
      run_examples(reporter)
    end.then do |result_for_this_group|
      puts "process descendants result is #{result_for_this_group}"
      process_descendants(result_for_this_group, reporter)
    end.rescue do |ex|
      puts "deal with ex #{ex}"
      case ex
      when Pending::SkipDeclaredInExample
        for_filtered_examples(reporter) { |example| example.skip_with_exception(reporter, ex) }
        true
      when Support::AllExceptionsExceptOnesWeMustNotRescue
        for_filtered_examples(reporter) { |example| example.fail_with_exception(reporter, ex) }
        RSpec.world.wants_to_quit = true if reporter.fail_fast_limit_met?
        false
      else
        puts "Unexpected exception! #{ex}"
        raise ex
      end
    end.ensure do |result|
      puts 'run after hooks begin'
      run_after_context_hooks(new('after(:context) hook')) if should_run_context_hooks
      puts 'run after hooks end'
      reporter.example_group_finished(self)
      puts "reported too, result is #{result}"
      # promise always do not behave exactly like ensure, need to be explicit about value being returned
      result
    end
  end

  # Promise oriented version
  def self.run_examples(reporter)
    examples = ordering_strategy.order(filtered_examples)
    return Promise.value(true) if examples.empty?

    example_promise = lambda do |example|
      next Promise.value(nil) if RSpec.world.wants_to_quit
      instance = new(example.inspect_output)
      set_ivars(instance, before_context_ivars)
      # Always returns a promise since we modified the Example class
      r = example.run(instance, reporter)
      puts "for example #{example}, result is #{r}"
      r
    end

    results = []
    # Can use true for this because we're AND'ing everything anyways
    seed = Promise.value(true)
    latest_promise = examples.inject(seed) do |previous_promise, next_example|
      previous_promise.then do |succeeded|
        puts "previous_promise succeed #{succeeded}"
        if !succeeded && reporter.fail_fast_limit_met?
          RSpec.world.wants_to_quit = true
        end
        results << succeeded
        example_promise[next_example]
      end
    end

    latest_promise.then do |succeeded|
      puts "last pormiser succeed #{succeeded}"
      if !succeeded && reporter.fail_fast_limit_met?
        RSpec.world.wants_to_quit = true
      end
      results << succeeded
      results.all?
    end
  end
end
