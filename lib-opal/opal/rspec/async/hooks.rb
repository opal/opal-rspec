class RSpec::Core::Hooks::HookCollection
  def run
    # WAS:
    #   hooks.each { |h| h.run(@example) }
    # NOW:
    hooks.inject(Promise.value(true)) do |previous_hook_promise, next_hook|
      previous_hook_promise.then do
        Promise.value(next_hook.run(@example))
      end
    end
  end
end
