# RSpec tries to add context with this. something like this: https://github.com/stacktracejs/stacktrace.js would be better than this but
# avoiding adding an NPM dependency for now
module Kernel
  def caller
    %x{
      function getErrorObject(){
          try { throw Error('') } catch(err) { return err; }
      }


      var err = getErrorObject();
    }
    stack = `err.stack`
    caller_lines = stack.split("\n")[4..-1]
    caller_lines.reject! {|l| l.strip.empty? }
    caller_lines.map do |raw_line|
      if match = /\s*at (.*) \((\S+):(\d+):\d+/.match(raw_line)
        method, filename, line = match.captures
        "#{filename}:#{line} in `#{method}'"
      elsif match = /\s*at (\S+):(\d+):\d+/.match(raw_line)
        filename, line = match.captures
        "#{filename}:#{line} in `(unknown method)'"
      # catch phantom/no 2nd line/col #
      elsif match = /\s*at (.*) \((\S+):(\d+)/.match(raw_line)
        method, filename, line = match.captures
        "#{filename}:#{line} in `#{method}'"
      elsif match = /\s*at (.*):(\d+)/.match(raw_line)
        filename, line = match.captures
        "#{filename}:#{line} in `(unknown method)'"
      else
        raise "Don't know how to parse #{raw_line}!"
      end
    end
  end
end
