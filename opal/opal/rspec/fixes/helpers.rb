# Missing on vendored rspec version
module RSpec
  module Core
    module MemoizedHelpers
      def is_expected
        expect(subject)
      end
    end
  end
end
