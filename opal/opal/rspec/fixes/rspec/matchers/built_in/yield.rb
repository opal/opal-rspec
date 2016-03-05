module ::RSpec::Matchers::BuiltIn
  class YieldWithArgs
    def description
      desc = "yield with args"
      # string mutation
      # desc << "(#{expected_arg_description})" unless @expected.empty?
      desc += "(#{expected_arg_description})" unless @expected.empty?
      desc
    end
  end
end
