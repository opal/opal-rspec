require 'opal/rspec/util'
require 'pathname'
require 'rake'
# require the bundled RSpec's file and don't rely on the load path in case opal-rspec is included in a project's
# Gemfile without rspec also being in the Gemfile
::Opal::RSpec.load_namespaced __dir__+'/../../../rspec-core/upstream/lib/rspec/core/ruby_project.rb', ::Opal

module Opal
  module RSpec
    class Locator
      include ::Opal::RSpec::Core::RubyProject

      DEFAULT_GLOB = '**{,/*/**}/*_spec{.js,}.{rb,opal}'
      DEFAULT_DEFAULT_PATH = 'spec-opal'

      attr_accessor :spec_pattern, :spec_exclude_pattern, :spec_files, :default_path

      def initialize(pattern: nil, exclude_pattern: nil, files: nil, default_path: nil)
        @spec_exclude_pattern = Array(exclude_pattern)
        @spec_files           = files
        @default_path         = default_path || DEFAULT_DEFAULT_PATH
        @spec_pattern         = Array(pattern || DEFAULT_GLOB)

        @spec_pattern = @spec_pattern.map do |pattern|
          pattern.sub(/\A#{Regexp.escape(@default_path)}/, '')
        end

        @spec_exclude_pattern = @spec_exclude_pattern.map do |pattern|
          pattern.sub(/\A#{Regexp.escape(@default_path)}/, '')
        end
      end

      def determine_root
        find_first_parent_containing(@default_path) || '.'
      end

      def get_spec_load_paths
        [File.join(root, @default_path)]
      end

      def get_matching_files_under(path: )
        FileList[*@spec_pattern.map { |i| "#{path}/#{i}" }]
          .exclude(*@spec_exclude_pattern.map { |i| "#{path}/#{i}" })
      end

      def get_opal_spec_requires
        if !@spec_files || @spec_files.empty?
          files = get_matching_files_under(path: @default_path)
        else
          files = @spec_files.map do |file|
            file = file.split(/[\[:]/).first
            if File.directory?(file)
              get_matching_files_under(path: file).to_a
            else
              file
            end
          end.flatten
          files = FileList[*files]
        end
        files.uniq.map { |file| File.expand_path file }
      end
    end
  end
end
