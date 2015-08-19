require 'pathname'

module Opal
  module RSpec    
    module PatternLogic
      DEFAULT_PATTERN = 'spec/**/*_spec.{rb,opal}'
      
      def get_opal_spec_paths
        glob_portion = /[\*\?\[\{].*/.match spec_pattern
        path = glob_portion ? spec_pattern.sub(glob_portion.to_s, '') : spec_pattern
        raise "Unable to identify a single root directory/file in the pattern #{spec_pattern}. Please adjust glob" unless File.exist?(path)
        [path]        
      end
            
      def get_opal_relative_specs
        Dir.glob(spec_pattern).map do |file|
          relative_path = get_relative_spec_path file
          # These will go directly into require '...' statements in Opal, so need to trim extensions
          relative_path.sub File.extname(relative_path), ''
        end
      end
      
      # help sprockets_runner chop off the base path
      def get_relative_spec_path(spec_file)
        spec_file = Pathname.new spec_file
        matching = nil
        get_opal_spec_paths.map {|p| Pathname.new p}.each do |spec_base_path|
          begin
            matching = spec_file.relative_path_from spec_base_path
            break
          rescue ArgumentError # expensive but most of the time, should match the first one
            # wrong path
            nil
          end
        end
        raise "Unable to find matching base path for #{spec_file} inside #{get_opal_spec_paths}" unless matching
        matching.to_s
      end
    end
    
    class SprocketsEnvironment < ::Sprockets::Environment
      # accessible from config.ru
      include PatternLogic
      
      attr_accessor :spec_pattern
      
      def initialize(spec_pattern=DEFAULT_PATTERN)
        @spec_pattern = spec_pattern
        super()
      end
      
      def cached
        CachedEnvironment.new(self)
      end
    end
    
    class CachedEnvironment < ::Sprockets::CachedEnvironment
      # from the ERB
      include PatternLogic
      
      attr_reader :spec_pattern
      
      def initialize(environment)
        super
        @spec_pattern = environment.spec_pattern
      end
    end
  end
end
