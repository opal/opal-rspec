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
