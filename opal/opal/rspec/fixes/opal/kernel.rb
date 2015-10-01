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
        filename,line = match.captures
        result_formatter[filename, line]
      else
        "#{filename}:-1 in `(can't parse this stack trace)`"
      end
    end
  end
end
