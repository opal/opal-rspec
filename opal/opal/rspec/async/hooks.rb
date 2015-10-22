class RSpec::Core::Hooks::HookCollection
  def run
    hooks.inject(Promise.value(true)) do |previous_hook_promise, next_hook|
      previous_hook_promise.then do
        result = next_hook.run @example
        Promise.value(result)
      end
    end
  end
end
