module ::RSpec::Core
  class Runner

    # Runs the suite of specs and exits the process with an appropriate exit code.
    def self.invoke
      disable_autorun!
      # WAS:
      #   status = run(ARGV, $stderr, $stdout).to_i
      #   exit(status) if status != 0
      # NOW:
      run(ARGV, $stderr, $stdout).then do |status|
        status = status.to_i
        exit(status) if status != 0
      end
    end

    def run_specs(example_groups)
      @configuration.reporter.report(@world.example_count(example_groups)) do |reporter|
        hook_context = SuiteHookContext.new("a `before(:suite)` hook", reporter)

        Promise.value(true).then do
          @configuration.hooks.run(:before, :suite, hook_context)

          # WAS: example_groups.map { |g| g.run(reporter) }.all? ? 0 : @configuration.failure_exit_code
          results = []
          example_groups.inject(Promise.value(true)) do |previous_promise, group|
            previous_promise.then do |result|
              results << result
              group.run reporter
            end
          end.then do |result|
            results << result
            results.all? ? 0 : @configuration.failure_exit_code
          end

        end.ensure do |result|
          hook_context = SuiteHookContext.new("an `after(:suite)` hook", reporter)
          @configuration.hooks.run(:after, :suite, hook_context)
          result
        end
      end
    end

  end
end
