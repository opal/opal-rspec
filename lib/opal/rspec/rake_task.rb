require 'opal/rspec'
require 'pathname'

module Opal
  module RSpec
    class RakeTask
      DEFAULT_PATTERN = 'spec/**/*_spec.{rb,opal}'
      include Rake::DSL if defined? Rake::DSL

      RUNNER = File.expand_path('../../../../vendor/spec_runner.js', __FILE__)
      PORT = 9999
      URL = "http://localhost:9999/"
      
      attr_accessor :pattern
      
      # TODO: Way to pass this to ERB/sprockets runner inside Rack besides class vars?
      @@opal_runner_pattern = nil
      @@opal_spec_paths = nil
      
      def self.get_opal_spec_paths
        @@opal_spec_paths ||= begin
          Pathname.glob(RakeTask.get_opal_runner_pattern).map {|p| p.dirname.to_s}.uniq
        end
      end
      
      def self.get_opal_runner_pattern
        @@opal_runner_pattern || DEFAULT_PATTERN
      end
      
      def self.get_opal_relative_specs
        Dir.glob(RakeTask.get_opal_runner_pattern).map do |file|
          relative_path = RakeTask.relative_spec_path file
          relative_path.sub File.extname(relative_path), ''
        end
      end
      
      # help sprockets_runner chop off the base path
      def self.relative_spec_path(spec_file)
        spec_file = Pathname.new spec_file
        matching = nil
        RakeTask.get_opal_spec_paths.map {|p| Pathname.new p}.each do |spec_base_path|
          begin
            matching = spec_file.relative_path_from spec_base_path
            break
          rescue ArgumentError
            # wrong path
            nil
          end
        end
        raise "Unable to find matching base path for #{spec_file} inside #{spec_paths}" unless matching
        matching.to_s
      end

      def initialize(name = 'opal:rspec', &block)
        @pattern = DEFAULT_PATTERN
        @@opal_spec_paths = nil # avoid testing issues
        desc "Run opal specs in phantomjs"
        task name do
          require 'rack'
          require 'webrick'

          app = Opal::Server.new { |s|
            s.main = 'opal/rspec/sprockets_runner'
            s.debug = false

            block.call s, self if block
            # sprockets_runner inside Rack will need to get at this
            @@opal_runner_pattern = self.pattern
            RakeTask.get_opal_spec_paths.each { |spec_path| s.append_path spec_path }
          }

          server = Thread.new do
            Thread.current.abort_on_exception = true
            Rack::Server.start(
              :app => app,
              :Port => PORT,
              :AccessLog => [],
              :Logger => WEBrick::Log.new("/dev/null"),
            )
          end

          if `phantomjs -v`.strip.to_i >= 2
            warn <<-WARN.gsub(/^              /,'')
              Only PhantomJS v1 is currently supported,
              if you're using homebrew on OSX you can switch version with:

                brew switch phantomjs 1.9.8

            WARN
            exit 1
          end

          begin
            system %Q{phantomjs #{RUNNER} "#{URL}"}
            success = $?.success?

            exit 1 unless success
          ensure
            server.kill
          end
        end
      end
    end
  end
end

