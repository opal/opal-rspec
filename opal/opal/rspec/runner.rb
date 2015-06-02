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
            Runner.new.run          
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
        run_examples.then do
          puts 'FINISH!'
          self.finish
        end        
      end

      def run_examples
        seed = Promise.value(true)
        last = @world.example_groups.inject(seed) do |previous_promise, group|
          previous_promise.then do |result|
            group.run @reporter
          end
        end
        puts 'runner, everything kicked off, waiting'
        last
      end    

      def config_hook(hook_when)
        hook_context = ::RSpec::Core::SuiteHookContext.new
        @configuration.hooks.run(hook_when, :suite, hook_context)
      end

      def config_hook(hook_when)
        hook_context = ::RSpec::Core::SuiteHookContext.new
        @configuration.hooks.run(hook_when, :suite, hook_context)
      end

      def start
        @reporter = @configuration.reporter
        @reporter.start(@world.example_count)
        config_hook :before
      end

      def finish
        config_hook :after
        @reporter.finish
      end
    end
  end
end
