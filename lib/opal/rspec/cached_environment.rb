require 'sprockets'
require 'opal/rspec/post_rack_locator'

module Opal
  module RSpec
    class CachedEnvironment < ::Sprockets::CachedEnvironment
      # this class is accessible from the ERB/runner file

      def initialize(env, pre_run_locator)
        super env
        @locator = RSpec::PostRackLocator.new(pre_run_locator)
      end

      def get_opal_spec_requires
        @locator.get_opal_spec_requires.map do |file|
          logical_path = find_asset(file).logical_path
          # These will go directly into require '...' statements in Opal, so need to trim extensions
          logical_path.sub File.extname(logical_path), ''
        end
      end
    end
  end
end
