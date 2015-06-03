class RSpec::Core::Hooks::HookCollection
  def run
    seed = Promise.value(nil)
    hooks.inject(seed) do |previous_hook_promise, next_hook|
      previous_hook_promise.then do
        result = next_hook.run @example
        result.is_a?(Promise) ? result : Promise.value(nil)
      end
    end
  end
end
