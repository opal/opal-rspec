require 'opal/rspec'

module Opal
  module RSpec
    class RakeTask
      include Rake::DSL if defined? Rake::DSL

      RUNNER = File.expand_path('../../../../vendor/spec_runner.js', __FILE__)
      PORT = 9999
      URL = "http://localhost:9999/"
      
      attr_accessor :pattern

      def initialize(name = 'opal:rspec', &block)
        @pattern = 'spec/**/*_spec.{rb,opal}' # default
        desc "Run opal specs in phantomjs"
        task name do
          require 'rack'
          require 'webrick'

          app = Opal::Server.new { |s|
            s.main = 'opal/rspec/sprockets_runner'
            s.append_path 'spec' # Pathname.glob('spec/**/*_spec.{rb,opal}').map {|p| p.dirname.to_s}.uniq
            s.debug = false

            block.call s, self if block
            ENV['PATTERN'] = self.pattern
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

