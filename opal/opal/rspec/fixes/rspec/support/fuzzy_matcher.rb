unless Opal::RSpec::Compatibility.lambda_zero_arg_throws_arg_error?
  module ::RSpec::Support::FuzzyMatcher
    def self.values_match?(expected, actual)
      if Array === expected && Enumerable === actual && !(Struct === actual)
        return arrays_match?(expected, actual.to_a)
      elsif Hash === expected && Hash === actual
        return hashes_match?(expected, actual)
      elsif actual == expected
        return true
      elsif expected.is_a?(Proc)
        return expected == actual
      end

      begin
        expected === actual
      rescue ArgumentError
        # Some objects, like 0-arg lambdas on 1.9+, raise
        # ArgumentError for `expected === actual`.
        false
      end
    end
  end
end
