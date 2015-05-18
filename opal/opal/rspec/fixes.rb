require 'encoding'

# This breaks on 2.0.0, so it is here ready for when opal bumps to 2.0.0
class RSpec::CallerFilter
  def self.first_non_rspec_line
    ""
  end
end

# Opal does not support mutable strings
module RSpec
  module Matchers
    module Pretty
      def underscore(camel_cased_word)
        word = camel_cased_word.to_s
        word = word.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
        word = word.gsub(/([a-z\d])([A-Z])/,'\1_\2')
        word = word.tr("-", "_")
        word = word.downcase
        word
      end
    end
  end
end

module RSpec::ExampleGroups
  # opal cannot use mutable strings AND opal doesnt support `\A` or `\z` anchors
  def self.base_name_for(group)
    return "Anonymous" if group.description.empty?

    # convert to CamelCase
    name = ' ' + group.description
    name = name.gsub(/[^0-9a-zA-Z]+([0-9a-zA-Z])/) { |m| m[1].upcase }

    name = name.lstrip         # Remove leading whitespace
    name = name.gsub(/\W/, '') # JRuby, RBX and others don't like non-ascii in const names

    # Ruby requires first const letter to be A-Z. Use `Nested`
    # as necessary to enforce that.
    name = name.gsub(/^([^A-Z]|$)/, 'Nested\1')

    name
  end

  # opal cannot use mutable strings
  def self.disambiguate(name, const_scope)
    return name unless const_scope.const_defined?(name)

    # Add a trailing number if needed to disambiguate from an existing constant.
    name = name + "_2"
    while const_scope.const_defined?(name)
      name = name.next
    end

    name
  end
end

# Opal does not support ObjectSpace, so force object __id__'s
class RSpec::Mocks::Space
  def id_for(object)
    object.__id__
  end
end

# Buggy under Opal?
class RSpec::Mocks::MethodDouble
  def save_original_method!
    @original_method ||= @method_stasher.original_method
  end
end

# Missing on vendored rspec version
module RSpec
  module Core
    module MemoizedHelpers
      def is_expected
        expect(subject)
      end
    end
  end
end

RSpec::Core::Formatters::DeprecationFormatter::GeneratedDeprecationMessage.class_eval do
  def to_s
    msg =  "#{@data[:deprecated]} is deprecated."
    msg += " Use #{@data[:replacement]} instead." if @data[:replacement]
    msg += " Called from #{@data[:call_site]}." if @data[:call_site]
    msg
  end

  def too_many_warnings_message
    msg = "Too many uses of deprecated '#{type}'."
    msg += " Set config.deprecation_stream to a File for full output."
    msg
  end
end

def (RSpec::Expectations).fail_with(message, expected=nil, actual=nil)
  if !message
    raise ArgumentError, "Failure message is nil. Does your matcher define the " +
                         "appropriate failure_message_for_* method to return a string?"
  end

  if actual && expected
    if all_strings?(actual, expected)
      if any_multiline_strings?(actual, expected)
        message # + "\nDiff:" + differ.diff_as_string(coerce_to_string(actual), coerce_to_string(expected))
      end
    elsif no_procs?(actual, expected) && no_numbers?(actual, expected)
      message # + "\nDiff:" + differ.diff_as_object(actual, expected)
    end
  end

  raise(RSpec::Expectations::ExpectationNotMetError.new(message))
end

class RSpec::Core::Reporter
  # https://github.com/opal/opal/issues/858
  # The problem is not directly related to the Reporter class (it has more to do with Formatter's call in add using a splat in the args list and right now, Opal does not run a to_a on a splat before the callee method takes over)
  def register_listener(listener, *notifications)
    # Unpack the splat unless it's already an array
    notifications = notifications[0].to_a unless notifications[0].is_a? Array
    notifications.each do |notification|
      @listeners[notification.to_sym] << listener
    end
    true
  end
end

# Thread usage in core.rb
require 'thread'

# RSpec tries to add color with this. something like this: https://github.com/stacktracejs/stacktrace.js would be better
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

class RSpec::Core::Formatters::DeprecationFormatter
  # mutable strings not supported
  SpecifiedDeprecationMessage = Struct.new(:type) do
    def initialize(data)
      @message = data.message
      super deprecation_type_for(data)
    end

    def to_s
      output_formatted @message
    end

    def too_many_warnings_message
      "Too many similar deprecation messages reported, disregarding further reports. " + DEPRECATION_STREAM_NOTICE      
    end

    private

    def output_formatted(str)
      return str unless str.lines.count > 1
      separator = "#{'-' * 80}"
      "#{separator}\n#{str.chomp}\n#{separator}"
    end

    def deprecation_type_for(data)
      data.message.gsub(/(\w+\/)+\w+\.rb:\d+/, '')
    end
  end

  GeneratedDeprecationMessage = Struct.new(:type) do
    def initialize(data)
      @data = data
      super data.deprecated
    end

    def to_s
      msg =  "#{@data.deprecated} is deprecated."
      msg = msg + " Use #{@data.replacement} instead." if @data.replacement
      msg = msg + " Called from #{@data.call_site}." if @data.call_site
      msg
    end

    def too_many_warnings_message
      "Too many uses of deprecated '#{type}'. " + DEPRECATION_STREAM_NOTICE
    end
  end
end

# Fix unnecessary deprecation warnings
# Hash.public_instance_methods - Object.public_instance_methods, which is a part of HashImitatable (included by ExecutionResult), returns the initialize method, which gets marked as deprecated (and that should not happen). Therefore we need to override the define_method that HashImitatable puts into place
class RSpec::Core::Example::ExecutionResult
  # There is no real constructor in example.rb's ExecutionResult class, so nothing needs to go here
  def initialize; end
end
