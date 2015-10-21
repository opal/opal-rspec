module RSpec::ExampleGroups
  # opal cannot use mutable strings AND opal doesnt support `\A` or `\z` anchors
  def self.base_name_for(group)
    return "Anonymous" if group.description.empty?

    # convert to CamelCase
    name = ' ' + group.description

    # replaced gsub! with name = name.gsub (mutable strings)
    name = name.gsub(/[^0-9a-zA-Z]+([0-9a-zA-Z])/) { Regexp.last_match[1].upcase }

    # mutable strings on these 2
    name = name.lstrip # Remove leading whitespace
    name = name.gsub(/\W/, '') # JRuby, RBX and others don't like non-ascii in const names

    # Ruby requires first const letter to be A-Z. Use `Nested`
    # as necessary to enforce that.
    # name.gsub!(/\A([^A-Z]|\z)/, 'Nested\1')
    # opal-rspec, mutable strings, also substituted in ^ for \A since \A and $ for \z is not supported in JS regex
    name = name.gsub(/^([^A-Z]|$)/, 'Nested\1')

    name
  end

  # opal cannot use mutable strings
  def self.disambiguate(name, const_scope)
    return name unless const_defined_on?(const_scope, name)

    # Add a trailing number if needed to disambiguate from an existing constant.
    name = name + "_2"

    while const_defined_on?(const_scope, name)
      name = name.next
    end

    name
  end
end

# https://github.com/opal/opal/issues/1080, fixed in Opal 0.9
unless Opal::RSpec::Compatibility.is_constants_a_clone?
  module RSpec::ExampleGroups
    original_constants = method(:constants)

    self.class.send(:define_method, :constants) do
      original_constants.call().dup
    end
  end
end
