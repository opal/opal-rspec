class Opal::RSpec::UpstreamTests::Runner
  def initialize(gem_name = ::RSpec.current_example.metadata[:gem_name])
    @gem_name = gem_name
    @config = Opal::RSpec::UpstreamTests::Config.new(gem_name)
  end

  def run
    @config.stubs.each { |f| ::Opal::Config.stubbed_files << f }

    output, exit_status = StdoutCapturingRunner.run { opal_rspec_runner.run }

    Opal::RSpec::UpstreamTests::Result.new(
      exit_status,
      output,
      JSON.parse(File.read("/tmp/#{@gem_name}-results.json"), symbolize_names: true),
    )
  end

  module StdoutCapturingRunner
    def self.run
      output_io = StringIO.new
      previous_stdout = $stdout
      previous_stderr = $stderr
      $stdout = output_io
      $stderr = output_io
      begin
        exit_status = yield
      ensure
        $stdout = previous_stdout
        $stderr = previous_stderr
      end
      output_io.rewind
      [output_io.read, exit_status]
    end
  end

  private

  def opal_rspec_runner
    ::Opal::RSpec::Runner.new do |server, task|
      # A lot of specs, can take longer on slower machines
      # task.timeout = 80000

      task.files = @config.files_to_run
      task.default_path = "#{@gem_name}/upstream/spec"

      @config.load_paths.each do |path|
        server.append_path(path)
      end

      server.debug = ENV['OPAL_DEBUG']
      task.requires.unshift(File.join(@config.submodule_root, 'spec/requires.rb'))
    end
  end
end
