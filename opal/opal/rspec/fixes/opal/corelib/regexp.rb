# https://github.com/opal/opal/pull/1129
unless Opal::RSpec::Compatibility.multiline_regex_works? && Opal::RSpec::Compatibility.empty_regex_works?
  class Regexp
    # https://github.com/opal/opal/pull/1129
    unless Opal::RSpec::Compatibility.empty_regex_works?
      class << self
        def allocate
          allocated = super
          `#{allocated}.un_initialized = true`
          allocated
        end
      end

      def options
        %x{
            if (self.un_initialized) {
              #{raise TypeError, 'uninitialized Regexp'}
            }
            var result = 0;
            // should be supported in IE6 according to https://msdn.microsoft.com/en-us/library/7f5z26w4(v=vs.94).aspx
            if (self.multiline) {
              result |= #{MULTILINE};
            }
            if (self.ignoreCase) {
              result |= #{IGNORECASE};
            }
            return result;
          }
      end
    end

    # https://github.com/opal/opal/pull/1129
    unless Opal::RSpec::Compatibility.regex_case_compare_works?
      def ===(string)
        `#{match(Opal.coerce_to?(string, String, :to_str))} !== nil`
      end
    end

    unless Opal::RSpec::Compatibility.multiline_regex_works?
      # https://github.com/opal/opal/pull/1129
      def match(string, pos = undefined, &block)
        %x{
          if (self.un_initialized) {
            #{raise TypeError, 'uninitialized Regexp'}
          }

          if (pos === undefined) {
            pos = 0;
          } else {
            pos = #{Opal.coerce_to(pos, Integer, :to_int)};
          }

          if (string === nil) {
            return #{$~ = nil};
          }

          string = #{Opal.coerce_to(string, String, :to_str)};

          if (pos < 0) {
            pos += string.length;
            if (pos < 0) {
              return #{$~ = nil};
            }
          }

          var source = self.source;
          var flags = 'g';
          // m flag + a . in Ruby will match white space, but in JS, it only matches beginning/ending of lines, so we get the equivalent here
          if (self.multiline) {
            source = source.replace('.', "[\\s\\S]");
            flags += 'm';
          }

          // global RegExp maintains state, so not using self/this
          var md, re = new RegExp(source, flags + (self.ignoreCase ? 'i' : ''));

          while (true) {
            md = re.exec(string);
            if (md === null) {
              return #{$~ = nil};
            }
            if (md.index >= pos) {
              #{$~ = MatchData.new(`re`, `md`)}
              return block === nil ? #{$~} : #{block.call($~)};
            }
            re.lastIndex = md.index + 1;
          }
        }
      end
    end
  end
end
