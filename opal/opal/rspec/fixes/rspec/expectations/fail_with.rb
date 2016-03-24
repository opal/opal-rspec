module Opal
  module RSpec
    class NoopDiffer
      def diff(*)
        ''
      end
    end
  end
end

module RSpec
  module Expectations
    class << self
      # No differ in opal
      # # @private
      # def differ
      #   RSpec::Support::Differ.new(
      #     :object_preparer => lambda { |object| RSpec::Matchers::Composable.surface_descriptions_in(object) },
      #     :color => RSpec::Matchers.configuration.color?
      #   )
      # end

      def differ
        Opal::RSpec::NoopDiffer.new
      end
    end
  end
end
