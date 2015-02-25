require 'opal/rspec'

module Opal
  module RSpec
    class RakeTask
      include Rake::DSL if defined? Rake::DSL

      RUNNER = File.expand_path('../../../../vendor/spec_runner.js', __FILE__)
      PORT = 9999
      URL = "http://localhost:9999/"

      def initialize(name = 'opal:rspec', &block)
        desc "Run opal specs in phantomjs"
        task name do
          require 'rack'
          require 'webrick'

          server = Thread.new do
            app = Opal::Server.new { |s|
              s.main = 'opal/rspec/sprockets_runner'
              s.append_path 'spec'
              s.debug = false

              block.call s if block
            }

            Rack::Server.start(:app => app, :Port => PORT, :AccessLog => [],
              :Logger => WEBrick::Log.new("/dev/null"))
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

