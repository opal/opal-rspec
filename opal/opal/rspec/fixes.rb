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
