require 'sprockets'

module Opal
  module RSpec
    class CachedEnvironment < ::Sprockets::CachedEnvironment
      # this class is accessible from the ERB/runner file

      def initialize(env, locator)
        super env
        @locator = locator
      end

      def get_opal_spec_requires
        @locator.get_opal_spec_requires.map do |file|
          asset = find_asset(file)
          unless asset
            raise "Unable to find asset for file #{file} within load paths. Check your load path/file specification.\n"+
                  "Searched paths:\n- #{paths.join("\n- ")}\n"

          end
          logical_path = asset.logical_path
          # These will go directly into require '...' statements in Opal, so need to trim extensions
          logical_path.sub File.extname(logical_path), ''
        end
      end
    end
  end
end
