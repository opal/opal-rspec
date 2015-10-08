unless Opal::RSpec::Compatibility.exception_inspect_matches?
  # https://github.com/opal/opal/pull/1134
  # only doing this fix in the tests since it's actual uses of opal-rspec will probably not zero in on the failure
  Exception.remove_method(:to_s)
  class Exception
    def self.new(message=nil)
      %x{
          var err = new self.$$alloc(message);

          if (Error.captureStackTrace) {
            Error.captureStackTrace(err);
          }

          err.name = self.$$name;
          err.$initialize(message);
          return err;
        }
    end

    def message
      @message || self.class.to_s
    end

    alias to_s message

    def inspect
      as_str = to_s
      as_str.empty? ? self.class.to_s : "#<#{self.class.to_s}: #{to_s}>"
    end
  end
end

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
