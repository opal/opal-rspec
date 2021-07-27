class RSpec::Core::Hooks::HookCollections
  def run(position, scope, example_or_group)
    return if RSpec.configuration.dry_run?

    x = if scope == :context
      unless example_or_group.class.metadata[:skip]
        run_owned_hooks_for(position, :context, example_or_group)
      end
    else
      case position
      when :before then run_example_hooks_for(example_or_group, :before, :reverse_each)
      when :after  then run_example_hooks_for(example_or_group, :after,  :each)
      when :around then run_around_example_hooks_for(example_or_group) { yield }
      end
    end

    # Some hooks can be async? I see a lot of problems here. Let's for now
    # fulfill the async API.
    Promise.value(x)
  end
end
