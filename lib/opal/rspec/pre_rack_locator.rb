require 'pathname'
# require the bundled RSpec's file and don't rely on the load path in case opal-rspec is included in a project's
# Gemfile without rspec also being in the Gemfile
require_relative '../../../rspec-core/lib/rspec/core/ruby_project'

module Opal
  module RSpec
    class PreRackLocator
      include ::RSpec::Core::RubyProject

      DEFAULT_PATTERN = 'spec/**/*_spec.{rb,opal}'
      DEFAULT_DEFAULT_PATH = 'spec'

      attr_accessor :spec_pattern, :spec_exclude_pattern, :spec_files, :default_path

      def initialize(spec_pattern=nil, spec_exclude_pattern=nil, spec_files=nil, default_path=nil)
        @spec_pattern = spec_pattern || DEFAULT_PATTERN
        @spec_exclude_pattern = spec_exclude_pattern
        @spec_files = spec_files
        @default_path = default_path || DEFAULT_DEFAULT_PATH
      end

      def determine_root
        find_first_parent_containing(@default_path) || '.'
      end

      def get_spec_load_paths
        [@default_path].map { |dir| File.join(root, dir) }
      end
    end
  end
end
