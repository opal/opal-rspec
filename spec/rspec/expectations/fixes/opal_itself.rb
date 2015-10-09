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

# https://github.com/opal/opal/pull/1135
unless Opal::RSpec::Compatibility.ostruct_works_right?
  class OpenStruct
    def initialize(hash = nil)
      @table = {}

      hash.each_pair { |key, value|
        @table[new_ostruct_member(key)] = value
      } if hash
    end

    def []=(name, value)
      @table[new_ostruct_member(name)] = value
    end

    def method_missing(name, *args)
      if args.length > 2
        raise NoMethodError.new "undefined method `#{name}' for #<OpenStruct>"
      end
      if name.end_with? '='
        if args.length != 1
          raise ArgumentError.new "wrong number of arguments (0 for 1)"
        end
        @table[new_ostruct_member(name[0 .. -2])] = args[0]
      else
        @table[name.to_sym]
      end
    end

    attr_reader :table

    def delete_field(name)
      sym = name.to_sym
      begin
        singleton_class.__send__(:remove_method, sym, "#{sym}=")
      rescue NameError
      end
      @table.delete sym
    end

    def new_ostruct_member(name)
      name = name.to_sym
      unless respond_to?(name)
        define_singleton_method(name) { @table[name] }
        define_singleton_method("#{name}=") { |x| @table[name] = x }
      end
      name
    end

    `var ostruct_ids;`

    def inspect
      %x{
          var top = (ostruct_ids === undefined),
              ostruct_id = self.$object_id();
        }
      begin
        result = "#<#{self.class}"
        %x{
            if (top) {
              ostruct_ids = {};
            }

            if (ostruct_ids.hasOwnProperty(ostruct_id)) {
              return #{result + ' ...>'};
            }

            ostruct_ids[ostruct_id] = true;
          }

        result += ' ' if @table.any?

        result += each_pair.map { |name, value|
          "#{name}=#{value.inspect}"
        }.join ", "

        result += ">"

        result
      ensure
        %x{
            if (top) {
              ostruct_ids = undefined;
            }
          }
      end
    end

    alias to_s inspect
  end
end
