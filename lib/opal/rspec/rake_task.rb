require 'opal/rspec'
require 'opal/rspec/cached_environment'
require 'opal/rspec/sprockets_environment'

module Opal
  module RSpec
    class RakeTask
      include Rake::DSL if defined? Rake::DSL

      RUNNER = File.expand_path('../../../../vendor/spec_runner.js', __FILE__)
      PORT = 9999
      URL = "http://localhost:9999/"
      
      attr_accessor :pattern
      attr_accessor :exclude_pattern
      attr_accessor :files
                  
      def launch_phantom
        system %Q{phantomjs #{RUNNER} "#{URL}"}
        success = $?.success?

        exit 1 unless success
      end

      def initialize(name = 'opal:rspec', &block)
        desc "Run opal specs in phantomjs"
        task name do          
          require 'rack'
          require 'webrick'

          sprockets_env = Opal::RSpec::SprocketsEnvironment.new
          app = Opal::Server.new(sprockets: sprockets_env) { |s|
            s.main = 'opal/rspec/sprockets_runner'
            s.debug = false

            block.call s, self if block
            sprockets_env.spec_pattern = self.pattern if self.pattern
            sprockets_env.spec_exclude_pattern = self.exclude_pattern
            sprockets_env.spec_files = self.files
            raise 'Cannot supply both a pattern and files!' if self.files and self.pattern
            sprockets_env.get_opal_spec_paths.each { |spec_path| s.append_path spec_path }
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
            launch_phantom
          ensure
            server.kill
          end
        end
      end
    end
  end
end

