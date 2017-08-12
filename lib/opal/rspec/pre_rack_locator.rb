require 'pathname'
# require the bundled RSpec's file and don't rely on the load path in case opal-rspec is included in a project's
# Gemfile without rspec also being in the Gemfile
require_relative '../../../rspec-core/lib/rspec/core/ruby_project'

module Opal
  module RSpec
    class PreRackLocator
      include ::RSpec::Core::RubyProject

      DEFAULT_PATTERN = 'spec-opal/**/*_spec.{rb,opal}'
      DEFAULT_DEFAULT_PATH = 'spec-opal'

      attr_accessor :spec_pattern, :spec_exclude_pattern, :spec_files, :default_path

      def initialize(pattern: nil, exclude_pattern: nil, files: nil, default_path: nil)
        @spec_pattern         = pattern || DEFAULT_PATTERN
        @spec_exclude_pattern = exclude_pattern
        @spec_files           = files
        @default_path         = default_path || DEFAULT_DEFAULT_PATH
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
