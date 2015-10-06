# https://github.com/opal/opal/issues/1110, fixed in Opal 0.9
unless Opal::RSpec::Compatibility.class_within_class_new_works?
  # in recursive_const_methods_spec
  module ::RSpec::Support::Foo
    class Parent
      UNDETECTED = 'Not seen when looking up constants in Bar'
    end

    class Bar < Parent
      VAL = 10
    end
  end
end
