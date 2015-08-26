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
          phantom? ? ::RSpec::Core::Formatters::ProgressFormatter : BrowserFormatter
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

      def run()
        # see NoCarriageReturnIO source for why this is being done
        no_cr = NoCarriageReturnIO.new
        @configuration.error_stream = no_cr
        @configuration.output_stream = no_cr
        @world.announce_filters

        self.start
        run_examples.then do |result|          
          self.finish
          finish_with_code(result ? 0 : 1)
        end        
      end

      def run_examples
        results = []
        last_promise = @world.example_groups.inject(Promise.value) do |previous_promise, group|
          previous_promise.then do |result|
            results << result
            group.run @reporter
          end
        end
        last_promise.then do |result|
          results << result
          results.all?
        end
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
      
      def finish_with_code(code)
        %x{
          if (typeof(phantom) !== "undefined") {
            phantom.exit(code);
          }
          else {
            Opal.global.OPAL_SPEC_CODE = code;
          }
        }
      end
    end
  end
end
