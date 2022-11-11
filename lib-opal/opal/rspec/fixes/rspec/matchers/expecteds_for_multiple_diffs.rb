module RSpec
  module Matchers
    # @api private
    # Handles list of expected values when there is a need to render
    # multiple diffs. Also can handle one value.
    class ExpectedsForMultipleDiffs
      def self.truncated(description)
        return description if description.length <= DESCRIPTION_MAX_LENGTH
        description[0...DESCRIPTION_MAX_LENGTH - 3] + "..."
      end
    end
  end
end
