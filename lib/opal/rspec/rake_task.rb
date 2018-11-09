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

      def arity_checking?
        setting = @arity_checking || :enabled
        setting == :enabled
      end

      def launch_phantom(sprockets_env, main, &config_block)
        app = Opal::Server.new(sprockets: sprockets_env) { |server|
          server.main = main
          server.debug = false
          config_block.call(server)
        }

        server = Thread.new do
          require 'rack'
          require 'webrick'
          Thread.current.abort_on_exception = true
          Rack::Server.start(
            :app => app,
            :Port => PORT,
            :AccessLog => [],
            :Logger => WEBrick::Log.new("/dev/null"),
          )
        end

        wait_for_server

        version_output = begin
          `phantomjs -v`.strip
        rescue
          warn 'Could not find phantomjs command on path!'
          exit 1
        end

        if version_output.to_f < 2
          warn "PhantomJS >= 2.0 is required but version #{version_output} is installed!"
          exit 1
        end

        begin
          command_line = %Q{phantomjs #{RUNNER} "#{URL}"#{@timeout ? " #{@timeout}" : ''}}
          puts "Running #{command_line}"
          system command_line
          success = $?.success?

          exit 1 unless success
        ensure
          server.kill
        end
      end

      def runner
        ((via_env = ENV['RUNNER']) && via_env.to_sym) || @runner || :phantom
      end

      def launch_node(sprockets, main, &config_block)
        Opal.paths.each { |p| sprockets.append_path(p) } # Opal::Server does this

        config_block.call sprockets

        asset = sprockets[main]
        raise "Cannot find asset: #{main} in #{sprockets.inspect}" if asset.nil?

        Tempfile.create [main.to_s.gsub(/\W/, '.'), '.opal_rspec.js'] do |file|
          File.write file.path, asset.to_s + Opal::Sprockets.load_asset(main)

          command = "node #{file.path} 2>&1"
          puts "~~> Running #{command}"
          system command
          exit 1 unless $?.success?
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
          sprockets_env = Opal::RSpec::SprocketsEnvironment.new
          main = 'opal/rspec/sprockets_runner'
          current_task = self

          config_block = -> *args {
            args.insert(1, current_task)
            block.call *args if block

            sprockets_env.spec_pattern = current_task.pattern if current_task.pattern
            sprockets_env.spec_exclude_pattern = current_task.exclude_pattern
            sprockets_env.spec_files = current_task.files
            sprockets_env.default_path = current_task.default_path if current_task.default_path
            raise 'Cannot supply both a pattern and files!' if current_task.files and current_task.pattern
            sprockets_env.add_spec_paths_to_sprockets
            Opal::Config.arity_check_enabled = arity_checking?
          }

          case runner
          when :node then launch_node(sprockets_env, main, &config_block)
          when :phantom then launch_phantom(sprockets_env, main, &config_block)
          else raise "unknown runner type: #{runner.inspect}"
          end
        end
      end
    end
  end
end

