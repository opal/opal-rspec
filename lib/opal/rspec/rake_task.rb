require 'opal/rspec'
require 'tempfile'
require 'socket'

module Opal
  module RSpec
    class RakeTask
      include Rake::DSL if defined? Rake::DSL

      RUNNER = File.expand_path('../../../../vendor/spec_runner.js', __FILE__)
      PORT = 9999
      URL = "http://localhost:#{PORT}/"

      attr_accessor :pattern, :exclude_pattern, :files, :default_path, :runner, :timeout, :arity_checking

      def arity_checking
        current_opal = Gem::Dependency.new('opal', '>= 0.10').match?('opal', Gem::Version.new(Opal::VERSION).release.to_s)
        if !current_opal && @arity_checking != :disabled
          warn 'WARNING: arity checking only supported on >= Opal 0.10'
        end
        current_opal && (@arity_checking != :disabled) ? :enabled : :disabled
      end

      def launch_phantom(timeout_value)
        command_line = %Q{phantomjs #{RUNNER} "#{URL}"#{timeout_value ? " #{timeout_value}" : ''}}
        puts "Running #{command_line}"
        system command_line
        success = $?.success?

        exit 1 unless success
      end

      def runner
        ((via_env = ENV['RUNNER']) && via_env.to_sym) || @runner || :phantom
      end

      def get_load_asset_code(server)
        sprockets = server.sprockets
        name = server.main
        asset = sprockets[name]
        raise "Cannot find asset: #{name}" if asset.nil?
        Opal::Processor.load_asset_code(sprockets, name)
      end

      # TODO: Avoid the Rack server and compile directly
      def launch_node(server)
        compiled = Tempfile.new 'opal_rspec.js'
        begin
          uri = URI(URL)
          Net::HTTP.start uri.hostname, uri.port do |http|
            resp = http.get File.join('/assets', server.main)
            compiled.write resp.body
            load_asset_code = get_load_asset_code server
            compiled.write load_asset_code
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
        uri = URI(URL)
        while tries < 4 && !up
          tries += 1
          sleep 0.1
          begin
            # Using TCPSocket, not net/http open because executing the HTTP GET / will incur a decent delay just to check if the server is up
            # in order to better communicate to the user what is going on, save the actual HTTP request for the phantom/node run
            # the only objective here is to see if the Rack server has started
            socket = TCPSocket.new uri.hostname, uri.port
            up = true
            socket.close
          rescue Errno::ECONNREFUSED
            # server not up yet
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
            sprockets_env.default_path = self.default_path if self.default_path
            raise 'Cannot supply both a pattern and files!' if self.files and self.pattern
            sprockets_env.add_spec_paths_to_sprockets
          }

          Opal::Config.arity_check_enabled = arity_checking == :enabled

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
            if `phantomjs -v`.nil?
              warn "Could not find phantomjs command"
              exit 1
            end
          end

          begin
            is_phantom ? launch_phantom(timeout) : launch_node(app)
          ensure
            server.kill
          end
        end
      end
    end
  end
end

