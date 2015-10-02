module ::RSpec::Core
  class Runner
    class << self
      def browser?
        `typeof(document) !== "undefined"`
      end

      def phantom?
        `typeof(phantom) !== 'undefined' || typeof(OPAL_SPEC_PHANTOM) !== 'undefined'`
      end

      def node?
        `typeof(process) !== 'undefined' && typeof(process.versions) !== 'undefined'`
      end

      def non_browser?
        phantom? || node?
      end

      def autorun
        run(ARGV, $stderr, $stdout).then do |status|
          exit_with_code status.to_i
        end
      end

      def exit_with_code(code)
        # have to ignore OPAL_SPEC_PHANTOM for this one
        if `typeof(phantom) !== "undefined"`
          `phantom_exit(#{code})`
        elsif node?
          `process.exit(#{code})`
        else
          `Opal.global.OPAL_SPEC_CODE = #{code}`
        end
      end

      def run(args, err=$stderr, out=$stdout)
        options = ConfigurationOptions.new(args)
        new(options).run(err, out)
      end
    end

    def run_groups_async(example_groups, reporter)
      results = []
      last_promise = example_groups.inject(Promise.value) do |previous_promise, group|
        previous_promise.then do |result|
          results << result
          group.run reporter
        end
      end
      last_promise.then do |result|
        results << result
        results.all? ? 0 : @configuration.failure_exit_code
      end
    end

    def run_specs(example_groups)
      @configuration.reporter.report_async(@world.example_count(example_groups)) do |reporter|
        hook_context = SuiteHookContext.new
        Promise.value.then do
          @configuration.hooks.run(:before, :suite, hook_context)
          run_groups_async example_groups, reporter
        end.ensure do |result|
          @configuration.hooks.run(:after, :suite, hook_context)
          result
        end
      end
    end
  end
end
