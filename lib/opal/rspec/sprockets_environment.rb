require 'sprockets'
require 'pathname'
require 'opal/rspec/cached_environment'
require 'opal/rspec/locator'
require 'forwardable'

module Opal
  module RSpec
    class SprocketsEnvironment < ::Sprockets::Environment
      extend Forwardable
      # this class accessible from config.ru and the rask task initializer

      def_delegators :@locator,
                     :spec_pattern=,
                     :spec_pattern,
                     :spec_exclude_pattern=,
                     :spec_exclude_pattern,
                     :spec_files=,
                     :spec_files,
                     :default_path=,
                     :default_path

      def initialize(spec_pattern=nil, spec_exclude_pattern=nil, spec_files=nil, default_path=nil)
        @locator = Opal::RSpec::Locator.new(pattern: spec_pattern, exclude_pattern: spec_exclude_pattern, files: spec_files, default_path: default_path)
        super()
      end

      attr_reader :locator

      def add_spec_paths_to_sprockets
        locator.get_spec_load_paths.each { |p| append_path p }
      end

      def cached
        CachedEnvironment.new(self, @locator)
      end
    end
  end
end
