# https://github.com/opal/opal/pull/1104, fixed in Opal 0.9
# Opal hasn't been using $stdout as a default value
unless Opal::RSpec::Compatibility.pp_uses_stdout_default?
  class PP
    class << self
      if `(typeof(console) === "undefined" || typeof(console.log) === "undefined")`
        def pp(obj, out=$stdout, width=79)
          p(*args)
        end
      else
        def pp(obj, out=$stdout, width=79)
          if String === out
            out + obj.inspect + "\n"
          else
            out << obj.inspect + "\n"
          end
        end
      end

      alias :singleline_pp :pp
    end
  end
end
