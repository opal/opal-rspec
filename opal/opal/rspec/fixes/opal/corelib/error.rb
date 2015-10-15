unless Opal::RSpec::Compatibility.exception_inspect_matches?
  # https://github.com/opal/opal/pull/1134 and https://github.com/opal/opal/pull/1151
  # only doing this fix in the tests since it's actual uses of opal-rspec will probably not zero in on the failure
  Exception.remove_method(:to_s)
  class Exception
    def message
      to_s
    end

    def inspect
      as_str = to_s
      as_str.empty? ? self.class.to_s : "#<#{self.class.to_s}: #{to_s}>"
    end

    def to_s
      (@message && @message.to_s) || self.class.to_s
    end
  end
end

# https://github.com/opal/opal/pull/1151 - should be fixed in Opal 0.9
unless Opal::RSpec::Compatibility.exception_exception_method_works?
  class Exception
    def self.new(*args)
      %x{
          var message = (args.length > 0) ? args[0] : nil;
          var err = new self.$$alloc(message);

          if (Error.captureStackTrace) {
            Error.captureStackTrace(err);
          }

          err.name = self.$$name;
          err.$initialize.apply(err, args);
          return err;
        }
    end

    def self.exception(*args)
      new(*args)
    end

    def initialize(*args)
      `self.message = (args.length > 0) ? args[0] : nil`
    end

    def exception(str=nil)
      %x{
          if (str === nil || self === str) {
            return self;
          }

          var cloned = #{self.clone};
          cloned.message = str;
          return cloned;
        }
    end
  end
end
