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

# Module#include should also include constants (as should class subclassing)
RSpec::Core::ExampleGroup::AllHookMemoizedHash = RSpec::Core::MemoizedHelpers::AllHookMemoizedHash

# These two methods break because of instance_variables(). That method should ignore
# private variables added by opal. This breaks as we copy ._klass which makes these 
# collections think they are arrays as we copy the _klass property from an array
# 
# OR:
#
# it breaks because we copy all methods from array, and dont have our real send,
# __send__ and class methods. This is more likely
class RSpec::Core::Hooks::HookCollection
  `def.$send = Opal.Kernel.$send`
  `def.$__send__ = Opal.Kernel.$__send__`
  `def.$class = Opal.Kernel.$class`
end
