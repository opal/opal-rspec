module Opal
  module RSpec
    class Runner

      class << self
        def browser?
          `typeof(document) !== "undefined"`
        end

        def phantom?
          `typeof(phantom) !== 'undefined' || typeof(OPAL_SPEC_PHANTOM) !== 'undefined'`
        end

        def default_formatter
          if phantom?
            TextFormatter
          else # browser
            BrowserFormatter
          end
        end

        def autorun
          if browser?
            `setTimeout(function() { #{Runner.new.run} }, 0)`
          else # phantom
            Runner.new.run
          end
        end
      end

      def initialize(options = {})
        @options = options
        @world = ::RSpec.world
        @configuration = ::RSpec.configuration
      end

      def run(err=$stdout, out=$stdout)
        @configuration.error_stream = err
        @configuration.output_stream ||= out

        self.start
        run_examples

        run_async_examples do
          self.finish
        end
      end

      def run_examples
        @world.example_groups.map { |g| g.run(@reporter) }.all?
      end

      def run_async_examples(&block)
        AsyncRunner.new(self, @reporter, block).run
      end

      def start
        @reporter = @configuration.reporter
        @reporter.start(@world.example_count)
        @configuration.run_hook(:before, :suite)
      end

      def finish
        @configuration.run_hook(:after, :suite)
        @reporter.finish
      end
    end
  end
end
