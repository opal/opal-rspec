require 'promise'

class ::RSpec::Core::Configuration
  def with_suite_hooks_async
    return Promise.value(yield) if dry_run?

    hook_context = SuiteHookContext.new
    Promise.value(true).then do
      run_hooks_with(@before_suite_hooks, hook_context)
      yield
    end.ensure do |result|
      run_hooks_with(@after_suite_hooks, hook_context)
      result
    end
  end
end
