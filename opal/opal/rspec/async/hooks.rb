class RSpec::Core::Hooks::HookCollections
  def run_owned_hooks_for(position, scope, example_or_group)
    # matching_hooks_for(position, scope, example_or_group).each do |hook|
    #   hook.run(example_or_group)
    # end
    matching_hooks = matching_hooks_for(position, scope, example_or_group)
    matching_hooks.inject(Promise.value(true)) do |previous_hook_promise, next_hook|
      previous_hook_promise.then do
        result = next_hook.run(example_or_group)
        Promise.value(result)
      end
    end
  end
end
