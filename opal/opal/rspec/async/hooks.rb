class RSpec::Core::Hooks::HookCollection
  def run
    hooks.inject(Promise.value) do |previous_hook_promise, next_hook|
      previous_hook_promise.then do
        result = next_hook.run @example
        Promise.value result
      end
    end
  end
end

# Need to be able to work with a promise, but without modifying proxy, we can't get a promise back from our around hook
# therefore, modify this so that we pass a promise in
class RSpec::Core::Hooks::AroundHook
  def execute_with_promise(use_promise, example, procsy)
    Promise.value(example.instance_exec(procsy, &block)).then do
      unless procsy.executed?
        Pending.mark_skipped!(example, "#{hook_description} did not execute the example")
      end
      use_promise.resolve
    end.rescue do |ex|
      use_promise.reject ex
    end
  end
end

class RSpec::Core::Hooks::AroundHookCollection
  def run
    seed = [@initial_procsy, Promise.value]
    last_procsy, last_promise = hooks.inject(seed) do |procsy_and_around_hook_promise, around_hook|
      procsy, previous_hook_promise = procsy_and_around_hook_promise
      new_hook_promise = Promise.new
      new_procsy = procsy.wrap do
        previous_hook_promise.then do
          puts "BRADY: Executing hook #{around_hook} on example #{@example} with promise #{new_hook_promise}"
          around_hook.execute_with_promise new_hook_promise, @example, procsy
        end        
      end
      [new_procsy, new_hook_promise]
    end
    puts "BRADY: last procsy is #{last_procsy}"
    last_procsy.call
    last_promise        
  end
end
