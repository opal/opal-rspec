require 'rake'

module Opal
  module RSpec
    class PostRackLocator
      def initialize(pre_run_locator)
        @spec_pattern = pre_run_locator.spec_pattern
        @spec_exclude_pattern = pre_run_locator.spec_exclude_pattern
        @spec_files = pre_run_locator.spec_files
      end

      def get_opal_spec_requires
        files = @spec_files || FileList[*@spec_pattern].exclude(*@spec_exclude_pattern)
        files.uniq.map { |file| File.expand_path file }
      end
    end
  end
end
