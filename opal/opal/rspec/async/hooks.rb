class RSpec::Core::Hooks::HookCollections
  def run_owned_hooks_for(position, scope, example_or_group)
    # matching_hooks_for(position, scope, example_or_group).each do |hook|
    #   hook.run(example_or_group)
    # end
    matching_hooks = matching_hooks_for(position, scope, example_or_group)
    puts "matching hooks #{matching_hooks}"
    matching_hooks.inject(Promise.value(true)) do |previous_hook_promise, next_hook|
      previous_hook_promise.then do
        result = next_hook.run(example_or_group)
        Promise.value(result)
      end
    end
  end

  def run_example_hooks_for(example, position, each_method)
    groups = []
    # owner_parent_groups.__send__(each_method) do |group|
    #   group.hooks.run_owned_hooks_for(position, :example, example)
    # end
    owner_parent_groups.__send__(each_method) do |group|
      groups << group
    end
    groups.inject(Promise.value(true)) do |previous_group_promise, group|
      previous_group_promise.then do
        group.hooks.run_owned_hooks_for(position, :example, example)
      end
    end
  end
end
