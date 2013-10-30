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

# Opal does not yet support $1..$9 backrefs
class RSpec::Matchers::BuiltIn::BePredicate
  def prefix_and_expected(symbol)
    symbol.to_s =~ /^(be_(an?_)?)(.*)/
    return $~[1], $~[3]
  end
end

module RSpec::ExampleGroups
  def self.base_name_for(group)
    return "Anonymous" if group.description.empty?

    # convert to CamelCase
    name = ' ' + group.description
    name = name.gsub(/[^0-9a-zA-Z]+([0-9a-zA-Z])/) { |m| m[1].upcase }

    name = name.lstrip         # Remove leading whitespace
    name = name.gsub(/\W/, '') # JRuby, RBX and others don't like non-ascii in const names

    # Ruby requires first const letter to be A-Z. Use `Nested`
    # as necessary to enforce that.
    name = name.gsub(/^([^A-Z]|$)/, 'Nested$1')

    name
  end

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
