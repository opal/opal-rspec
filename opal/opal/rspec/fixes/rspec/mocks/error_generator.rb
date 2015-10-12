unless Opal::RSpec::Compatibility.constant_resolution_works_right?
  module ::RSpec::Mocks
    class MockExpectationError < Exception
    end

    # Raised when a test double is used after it has been torn
    # down (typically at the end of an rspec-core example).
    class ExpiredTestDoubleError < MockExpectationError
    end

    # Raised when doubles or partial doubles are used outside of the per-test lifecycle.
    class OutsideOfExampleError < StandardError
    end

    # @private
    class UnsupportedMatcherError < StandardError
    end

    # @private
    class NegationUnsupportedError < StandardError
    end

    # @private
    class VerifyingDoubleNotDefinedError < StandardError
    end
  end
end
