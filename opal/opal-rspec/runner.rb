module OpalRSpec
  class Runner
    def initialize(options={}, configuration=RSpec::configuration, world=RSpec::world)
      @options = options
      @configuration = configuration
      @world = world
    end

    def run(err=$stdout, out=$stdout)
      @configuration.error_stream = err
      @configuration.output_stream ||= out

      @configuration.reporter.report(@world.example_count) do |reporter|
        begin
          @configuration.run_hook(:before, :suite)
          @world.example_groups.map {|g| g.run(reporter) }.all? ? 0 : @configuration.failure_exit_code
        ensure
          @configuration.run_hook(:after, :suite)
        end
      end
    end
  end
end

