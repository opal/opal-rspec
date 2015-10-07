module ::RSpec::Matchers::BuiltIn
  class StartAndEndWith
    def failure_message
      msg = super
      if @actual_does_not_have_ordered_elements
        msg += ", but it does not have ordered elements"
      elsif !actual.respond_to?(:[])
        msg += ", but it cannot be indexed using #[]"
      end
      msg
      # string mutation
      # super.tap do |msg|
      #   if @actual_does_not_have_ordered_elements
      #     msg << ", but it does not have ordered elements"
      #   elsif !actual.respond_to?(:[])
      #     msg << ", but it cannot be indexed using #[]"
      #   end
      # end
    end

    # see StartWith and EndWith below
    def check_ordered_element(actual)
      # Opal arity checking off by default, will check it manually
      arity = actual.method(:[]).arity
      raise ArgumentError.new "wrong number of arguments (2 for #{arity})" unless arity == 2
    end
  end

  class StartWith
    def subset_matches?
      check_ordered_element actual
      values_match?(expected, actual[0, expected.length])
    end
  end

  class EndWith
    def subset_matches?
      check_ordered_element actual
      values_match?(expected, actual[-expected.length, expected.length])
    end
  end
end
