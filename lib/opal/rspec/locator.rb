require 'pathname'
require 'rake'
# require the bundled RSpec's file and don't rely on the load path in case opal-rspec is included in a project's
# Gemfile without rspec also being in the Gemfile
require_relative '../../../rspec-core/upstream/lib/rspec/core/ruby_project'

module Opal
  module RSpec
    class Locator
      include ::RSpec::Core::RubyProject

      DEFAULT_GLOB = '**{,/*/**}/*_spec{.js,}.{rb,opal}'
      DEFAULT_PATTERN = "spec-opal/#{DEFAULT_GLOB}"
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

      def get_opal_spec_requires
        files = @spec_files || FileList[*@spec_pattern].exclude(*@spec_exclude_pattern)
        files.uniq.map { |file| File.expand_path file }
      end
    end
  end
end
