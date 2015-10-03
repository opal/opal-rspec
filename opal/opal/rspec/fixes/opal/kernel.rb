module Kernel
  unless Opal::RSpec::Compatibility.clones_singleton_methods?
    def copy_singleton_methods(other)
      %x{
            var name;
            if (other.hasOwnProperty('$$meta')) {
              var other_singleton_class_proto = Opal.get_singleton_class(other).$$proto;
              var self_singleton_class_proto = Opal.get_singleton_class(self).$$proto;
              for (name in other_singleton_class_proto) {
                if (name.charAt(0) === '$' && other_singleton_class_proto.hasOwnProperty(name)) {
                  self_singleton_class_proto[name] = other_singleton_class_proto[name];
                }
              }
            }
            for (name in other) {
              if (name.charAt(0) === '$' && name.charAt(1) !== '$' && other.hasOwnProperty(name)) {
                self[name] = other[name];
              }
            }
          }
    end

    def clone
      copy = self.class.allocate

      copy.copy_instance_variables(self)
      copy.copy_singleton_methods(self)
      copy.initialize_clone(self)

      copy
    end
  end

  # RSpec tries to add context with this. something like this: https://github.com/stacktracejs/stacktrace.js would be better than this but
  # avoiding adding an NPM dependency for now
  def caller
    %x{
      function getErrorObject(){
          try { throw Error('') } catch(err) { return err; }
      }


      var err = getErrorObject();
    }
    stack = `err.stack`
    caller_lines = stack.split("\n")[4..-1]
    caller_lines.reject! { |l| l.strip.empty? }

    result_formatter = lambda do |filename, line, method=nil|
      "#{filename}:#{line} in `(#{method ? method : 'unknown method'})'"
    end

    caller_lines.map do |raw_line|
      if match = /\s*at (.*) \((\S+):(\d+):\d+/.match(raw_line)
        method, filename, line = match.captures
        result_formatter[filename, line, method]
      elsif match = /\s*at (\S+):(\d+):\d+/.match(raw_line)
        filename, line = match.captures
        result_formatter[filename, line]
        # catch phantom/no 2nd line/col #
      elsif match = /\s*at (.*) \((\S+):(\d+)/.match(raw_line)
        method, filename, line = match.captures
        result_formatter[filename, line, method]
      elsif match = /\s*at (.*):(\d+)/.match(raw_line)
        filename, line = match.captures
        result_formatter[filename, line]
        # Firefox - Opal.modules["rspec/core/metadata"]/</</</</def.$populate@http://192.168.59.103:9292/assets/rspec/core/metadata.self.js?body=1:102:13
      elsif match = /(.*?)@(\S+):(\d+):\d+/.match(raw_line)
        method, filename, line = match.captures
        result_formatter[filename, line, method]
        # webkit - http://192.168.59.103:9292/assets/opal/rspec/sprockets_runner.js:45117:314
      elsif match = /(\S+):(\d+):\d+/.match(raw_line)
        filename, line = match.captures
        result_formatter[filename, line]
      else
        "#{filename}:-1 in `(can't parse this stack trace)`"
      end
    end
  end
end
