# await: *await*

module ::RSpec::Core
  class Runner

    # Runs the suite of specs and exits the process with an appropriate exit code.
    def self.invoke
      disable_autorun!
      # WAS:
      #   status = run(ARGV, $stderr, $stdout).to_i
      #   exit(status) if status != 0
      # NOW:
      status = run_await(ARGV, $stderr, $stdout).to_i
      exit(status)
    end

    def self.run_await(args, err=$stderr, out=$stdout)
      trap_interrupt
      options = ConfigurationOptions.new(args)

      if options.options[:runner]
        options.options[:runner].call(options, err, out)
      else
        new(options).run_await(err, out)
      end
    end

    def run_await(err, out)
      setup(err, out)
      return @configuration.reporter.exit_early(exit_code) if RSpec.world.wants_to_quit

      run_specs_await(@world.ordered_example_groups).tap do
        persist_example_statuses
      end
    end

    def run_specs_await(example_groups)
      examples_count = @world.example_count(example_groups)

      examples_passed = @configuration.reporter.report_await(examples_count) do |reporter|
        @configuration.with_suite_hooks_await do
          if examples_count == 0 && @configuration.fail_if_no_examples
            return @configuration.failure_exit_code
          end

          example_groups.map_await { |g| g.run_await(reporter) }.all?
        end
      end

      exit_code(examples_passed)
    end
  end
end
