require 'opal/rspec/runner'

module Opal
  module RSpec
    class RakeTask
      def initialize(name = 'opal:rspec', &block)
        runner = ::Opal::RSpec::Runner.new(&block)
        desc 'Run Opal specs'
        task name do
          sh runner.command
        end
      end
    end
  end
end

