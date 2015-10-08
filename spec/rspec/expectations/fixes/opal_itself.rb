# https://github.com/opal/opal/issues/1110, fixed in Opal 0.9
unless Opal::RSpec::Compatibility.class_within_class_new_works?
  require 'delegate'

  class ArrayDelegate < DelegateClass(Array)
    def initialize(array)
      @internal_array = array
      super(@internal_array)
    end

    def large?
      @internal_array.size >= 5
    end
  end

  class FooError < StandardError
    def foo;
      :bar;
    end
  end

  # description_generaiton_spec
  class Parent;
  end
  class Child < Parent
    def child_of?(*parents)
      parents.all? { |parent| self.is_a?(parent) }
    end
  end

  # be_between spec
  class SizeMatters
    include Comparable
    attr :str

    def <=>(other)
      str.size <=> other.str.size
    end

    def initialize(str)
      @str = str
    end

    def inspect
      @str
    end
  end
end

unless Opal::RSpec::Compatibility.exception_inspect_matches?
  # https://github.com/opal/opal/pull/1134
  class Exception
    def inspect
      class_str = self.class.to_s
      our_str = to_s
      our_str.empty? ? class_str : "#<#{class_str}: #{our_str == class_str ? @message : our_str}>"
    end
  end
end
