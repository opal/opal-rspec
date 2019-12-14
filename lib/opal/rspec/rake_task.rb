require 'rake'
require 'opal/rspec/runner'

module Opal
  module RSpec
    class RakeTask
      include Rake::DSL
      DEFAULT_NAME = 'spec:opal'
      attr_reader :rake_task

      def initialize(name = DEFAULT_NAME, &block)
        runner = ::Opal::RSpec::Runner.new(&block)
        desc 'Run Opal specs'
        @rake_task = task name do
          exit runner.run
        end
      end
    end
  end
end

