module ::RSpec::Mocks
  unless Opal::RSpec::Compatibility.constant_resolution_works_right?
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

  class ErrorGenerator
    def actual_method_call_args_description(count, args)
      method_call_args_description(args) ||
          if count > 0 && args.length > 0
            # \A and \z not supported on Opal
            # " with arguments: #{args.inspect.gsub(/\A\[(.+)\]\z/, '(\1)')}"
            " with arguments: #{args.inspect.gsub(/^\[(.+)\]$/, '(\1)')}"
          else
            ""
          end
    end
  end
end
