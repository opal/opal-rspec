# https://github.com/opal/opal/issues/1110, fixed in Opal 0.9
unless Opal::RSpec::Compatibility.class_within_class_new_works?
  class ExpiredInstanceInterface
    def foo;
    end

    def bar;
    end

    def bazz;
    end
  end

  class ExpiredClassInterface
    def self.foo;
    end

    def self.bar;
    end

    def self.bazz;
    end
  end

  class ExampleClass
    def hello
      :hello_defined_on_class
    end
  end
end
