require_relative 'formatter/opal_closed_tty_io'

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

      def get_opal_closed_tty_io
        runner_type = if phantom?
                        :phantom
                      elsif node?
                        :node
                      else
                        :browser
                      end
        std_out = OpalClosedTtyIO.new runner_type,
                                      :stdout
        std_err = OpalClosedTtyIO.new runner_type,
                                      :stderr
        [std_err, std_out]
      end

      def invoke
        disable_autorun!
        # see NoCarriageReturnIO source for why this is being done (not on Node though)
        err, out = get_opal_closed_tty_io
        # Have to do this in 2 places. This will ensure the default formatter gets the right IO, but need to do this in config for custom formatters
        # that will be constructed BEFORE this runs, see rspec.rb
        run(ARGV, err, out).then do |status|
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
      last_promise = example_groups.inject(Promise.value(true)) do |previous_promise, group|
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
      # new
      @configuration.reporter.report_async(@world.example_count(example_groups)) do |reporter|
        @configuration.with_suite_hooks_async do
          run_groups_async example_groups, reporter
        end
      end
    end

    def persist_example_statuses
      # We don't support this right now, so make it a noop
    end
  end
end
