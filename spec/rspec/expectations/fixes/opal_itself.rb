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
end