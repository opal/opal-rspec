# String#<< is not supported by Opal
module RSpec::Expectations
  def self.fail_with(message, expected = nil, actual = nil)
    if !message
      raise ArgumentError, "Failure message is nil. Does your matcher define the " +
                           "appropriate failure_message_for_* method to return a string?"
    end

    raise RSpec::Expectations::ExpectationNotMetError.new(message)
  end
end

# Opal does not support mutable strings
module RSpec::Matchers::Pretty
  def underscore(camel_cased_word)
    word = camel_cased_word.to_s.dup
    word = word.gsub(/([A-Z]+)([A-Z][a-z])/,'$1_$2')
    word = word.gsub(/([a-z\d])([A-Z])/,'$1_$2')
    word = word.tr("-", "_")
    word = word.downcase
    word
  end
end

# make sure should and expect syntax are both loaded
RSpec::Expectations::Syntax.enable_should
RSpec::Expectations::Syntax.enable_expect

# opal doesnt yet support module_exec for defining methods in modules properly
module RSpec::Matchers
  alias_method :expect, :expect
end

# enable_should uses module_exec which does not donate methods to bridged classes
module Kernel
  alias should should
  alias should_not should_not
end

# Module#include should also include constants (as should class subclassing)
RSpec::Core::ExampleGroup::AllHookMemoizedHash = RSpec::Core::MemoizedHelpers::AllHookMemoizedHash

# bad.. something is going wrong inside hooks - so set hooks to empty, for now
# or is it a problem with Array.public_instance_methods(false) adding all array
# methods to this class and thus breaking things like `self.class.new`
class RSpec::Core::Hooks::HookCollection
  def for(a)
    RSpec::Core::Hooks::HookCollection.new.with(a)
  end
end

class RSpec::Core::Hooks::AroundHookCollection
  def for(a)
    RSpec::Core::Hooks::AroundHookCollection.new.with(a)
  end
end

