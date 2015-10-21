require 'sprockets'

module Opal
  module RSpec    
    class CachedEnvironment < ::Sprockets::CachedEnvironment
      # this class is accessible from the ERB/runner file
            
      def initialize(environment)
        super
        @spec_pattern = environment.spec_pattern
        @spec_exclude_pattern = environment.spec_exclude_pattern
        @spec_files = environment.spec_files
      end
      
      def get_opal_spec_requires
        files = @spec_files || FileList[*@spec_pattern].exclude(*@spec_exclude_pattern)
        files.map do |file|
          expanded = File.expand_path file
          logical_path = find_asset(expanded).logical_path
          # These will go directly into require '...' statements in Opal, so need to trim extensions
          logical_path.sub File.extname(logical_path), ''
        end
      end    
    end
  end
end
