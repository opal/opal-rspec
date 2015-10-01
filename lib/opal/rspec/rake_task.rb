require 'opal/rspec'
require 'tempfile'

module Opal
  module RSpec
    class RakeTask
      include Rake::DSL if defined? Rake::DSL

      RUNNER = File.expand_path('../../../../vendor/spec_runner.js', __FILE__)
      PORT = 9999
      URL = "http://localhost:#{PORT}/"

      attr_accessor :pattern, :exclude_pattern, :files, :runner

      def launch_phantom
        command_line = %Q{phantomjs #{RUNNER} "#{URL}"}
        puts "Running #{command_line}"
        system command_line
        success = $?.success?

        exit 1 unless success
      end

      def runner
        ((via_env = ENV['RUNNER']) && via_env.to_sym) || @runner || :phantom
      end

      OTHER_JUNK = <<-JS
           if (typeof(Opal) !== 'undefined') {
              Opal.mark_as_loaded("opal");
      Opal.mark_as_loaded("corelib/runtime.self");
      Opal.mark_as_loaded("mutex_m");
      Opal.mark_as_loaded("prettyprint");
      Opal.mark_as_loaded("tempfile");
      Opal.mark_as_loaded("diff/lcs");
      Opal.mark_as_loaded("diff/lcs/block");
      Opal.mark_as_loaded("diff/lcs/callbacks");
      Opal.mark_as_loaded("diff/lcs/change");
      Opal.mark_as_loaded("diff/lcs/hunk");
      Opal.mark_as_loaded("diff/lcs/internals");
      Opal.mark_as_loaded("test/unit/assertions");
      Opal.mark_as_loaded("optparse");
      Opal.mark_as_loaded("shellwords");
      Opal.mark_as_loaded("socket");
      Opal.mark_as_loaded("uri");
      Opal.mark_as_loaded("drb/drb");
      Opal.mark_as_loaded("minitest/unit");
      Opal.mark_as_loaded("cgi/util");
              Opal.load("opal/rspec/sprockets_runner");
            }
      JS

      def launch_node
        compiled = Tempfile.new 'opal_rspec.js'
        begin
          # TODO: URL constant
          Net::HTTP.start 'localhost', 9999 do |http|
            # TODO: Supply the main runner path in here and just append to /assets/
            resp = http.get '/assets/opal/rspec/sprockets_runner.js'
            compiled.write resp.body
            compiled.write OTHER_JUNK
            compiled.close
          end
          command_line = "node #{compiled.path} 2>&1"
          puts "Running #{command_line}"
          system command_line
          exit 1 unless $?.success?
        ensure
          compiled.close unless compiled.closed?
          compiled.unlink
        end
      end

      def wait_for_server
        # avoid retryable dependency
        tries = 0
        up = false
        while tries < 4 && !up
          tries += 1
          sleep 0.1
          begin
            open URL
            up = true
          rescue Errno::ECONNREFUSED
            puts 'Server not up yet'
          end
        end
        raise 'Tried 4 times to contact Rack server and not up!' unless up
      end

      def initialize(name = 'opal:rspec', &block)
        desc 'Run opal specs in phantomjs/node'
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
            sprockets_env.add_spec_paths_to_sprockets
          }

          # TODO: Once Opal 0.9 compatibility is established, if we're running node, add in the node stdlib requires in so RSpec can use them, also add NODE_PATH to the runner command above

          server = Thread.new do
            Thread.current.abort_on_exception = true
            Rack::Server.start(
                :app => app,
                :Port => PORT,
                :AccessLog => [],
                :Logger => WEBrick::Log.new("/dev/null"),
            )
          end

          wait_for_server
          is_phantom = runner == :phantom
          if is_phantom
            if `phantomjs -v`.strip.to_i >= 2
              warn <<-WARN.gsub(/^              /, '')
                Only PhantomJS v1 is currently supported,
                if you're using homebrew on OSX you can switch version with:

                  brew switch phantomjs 1.9.8

              WARN
              exit 1
            end
          end

          begin
            is_phantom ? launch_phantom : launch_node
          ensure
            server.kill
          end
        end
      end
    end
  end
end

