require 'sprockets'
require 'pathname'
require 'opal/rspec/cached_environment'

module Opal
  module RSpec   
    class SprocketsEnvironment < ::Sprockets::Environment
      DEFAULT_PATTERN = 'spec/**/*_spec.{rb,opal}'
      # this class accessible from config.ru and the rask task initializer
      
      attr_accessor :spec_pattern, :spec_exclude_pattern, :spec_files      
      
      def initialize(spec_pattern=DEFAULT_PATTERN, spec_exclude_pattern=nil, spec_files=nil)
        @spec_pattern = spec_pattern
        @spec_exclude_pattern = spec_exclude_pattern
        @spec_files = spec_files
        super()
      end     
      
      def add_spec_paths_to_sprockets
        get_spec_load_paths.each {|p| append_path p }        
      end
      
      def cached
        CachedEnvironment.new(self)
      end
      
      private
      
      def get_spec_load_paths
        base_paths = spec_files ? get_files_directories : strip_globs_from_patterns
        # Want to get the smallest # of load paths that's common between our patterns
        array_or_single = base_paths.inject do |path1, path2|
          with_common_paths_replaced path1, path2            
        end
        [*array_or_single]
      end
      
      def strip_globs_from_patterns
        # only using spec_pattern here since we only need paths for inclusion
        [*spec_pattern].map do |each_pattern|
          glob_portion = /[\*\?\[\{].*/.match each_pattern
          path = glob_portion ? each_pattern.sub(glob_portion.to_s, '') : each_pattern
          raise "Unable to identify a single root directory/file in the pattern #{each_pattern}. Please adjust glob" unless File.exist?(path)
          path = Pathname.new path
          # in case a filename was used as a pattern
          path.directory? ? path : path.dirname
        end
      end
      
      def get_files_directories
        spec_files.map do |file|
          Pathname.new(file).dirname
        end.uniq        
      end
      
      def with_common_paths_replaced(existing_paths, new_path)
        new_path_covered = false
        replaced = [*existing_paths].map do |path|
          match = nil
          path.ascend do |each_level|
            new_path.ascend do |each_other_level|
              match = each_level if each_level.expand_path == each_other_level.expand_path
              break if match
            end
            break if match
          end
          if match
            new_path_covered = true
            match
          else
            path
          end
        end
        replaced << new_path unless new_path_covered
        replaced.uniq
      end
    end    
  end
end
