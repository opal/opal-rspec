require 'sprockets'
require 'pathname'

module Opal
  module RSpec    
    class CachedEnvironment < ::Sprockets::CachedEnvironment
      # this class is accessible from the ERB/runner file
            
      def initialize(environment)
        super
        @spec_pattern = environment.spec_pattern
        @spec_exclude_pattern = environment.spec_exclude_pattern
        @opal_spec_load_paths = environment.get_opal_spec_paths
        @spec_files = environment.spec_files
      end
      
      def get_opal_spec_requires
        files = @spec_files || FileList[*@spec_pattern].exclude(*@spec_exclude_pattern)
        files.map do |file|
          relative_path = get_relative_spec_path file
          # These will go directly into require '...' statements in Opal, so need to trim extensions
          relative_path.sub File.extname(relative_path), ''          
        end        
      end
      
      private
      
      # help sprockets_runner chop off the base path
      def get_relative_spec_path(spec_file)
        spec_file = Pathname.new spec_file
        matching = @opal_spec_load_paths.map do |spec_base_path|
          spec_file.expand_path.relative_path_from spec_base_path.expand_path
        end.find {|rel| !rel.to_s.include? '..'}
        raise "Unable to find matching base path for #{spec_file} inside #{@opal_spec_load_paths}" unless matching
        matching.to_s
      end
    end
  end
end
