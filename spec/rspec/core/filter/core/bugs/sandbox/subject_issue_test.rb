module RSpec
  def self.current_example=(ex)
    @ex = ex
  end

  def self.current_example
    @ex
  end
end

module MemoizedHelpers
  module ClassMethods
    def let(name, &block)
      MemoizedHelpers.module_for(self).__send__(:define_method, name, &block)

      define_method(name) {
        super(RSpec.current_example, &nil)
      }
    end

    def subject(name=nil, &block)
      if name
        let(name, &block)
        alias_method :subject, name

        self::NamedSubjectPreventSuper.__send__(:define_method, name) do
          raise NotImplementedError, "`super` in named subjects is not supported"
        end
      else
        let(:subject, &block)
      end
    end
  end

  def self.module_for(example_group)
    get_constant_or_yield(example_group, :LetDefinitions) do
      mod = Module.new do
        # Maybe same problem w/ scoping as class.new anon?
        include Module.new {
                  example_group.const_set(:NamedSubjectPreventSuper, self)
                }
      end

      example_group.const_set(:LetDefinitions, mod)
      mod
    end
  end

  def self.define_helpers_on(example_group)
    example_group.__send__(:include, module_for(example_group))
  end

  if Module.method(:const_defined?).arity == 1 # for 1.8
    # @private
    #
    # Gets the named constant or yields.
    # On 1.8, const_defined? / const_get do not take into
    # account the inheritance hierarchy.
    def self.get_constant_or_yield(example_group, name)
      if example_group.const_defined?(name)
        example_group.const_get(name)
      else
        yield
      end
    end
  else
    # @private
    #
    # Gets the named constant or yields.
    # On 1.9, const_defined? / const_get take into account the
    # the inheritance by default, and accept an argument to
    # disable this behavior. It's important that we don't
    # consider inheritance here; each example group level that
    # uses a `let` should get its own `LetDefinitions` module.
    def self.get_constant_or_yield(example_group, name)
      if example_group.const_defined?(name, (check_ancestors = false))
        example_group.const_get(name, check_ancestors)
      else
        yield
      end
    end
  end
end

module Support
  # Provides recursive constant lookup methods useful for
  # constant stubbing.
  module RecursiveConstMethods
    # We only want to consider constants that are defined directly on a
    # particular module, and not include top-level/inherited constants.
    # Unfortunately, the constant API changed between 1.8 and 1.9, so
    # we need to conditionally define methods to ignore the top-level/inherited
    # constants.
    #
    # Given:
    #   class A; B = 1; end
    #   class C < A; end
    #
    # On 1.8:
    #   - C.const_get("Hash") # => ::Hash
    #   - C.const_defined?("Hash") # => false
    #   - C.constants # => ["B"]
    #   - None of these methods accept the extra `inherit` argument
    # On 1.9:
    #   - C.const_get("Hash") # => ::Hash
    #   - C.const_defined?("Hash") # => true
    #   - C.const_get("Hash", false) # => raises NameError
    #   - C.const_defined?("Hash", false) # => false
    #   - C.constants # => [:B]
    #   - C.constants(false) #=> []
    if Module.method(:const_defined?).arity == 1
      def const_defined_on?(mod, const_name)
        mod.const_defined?(const_name)
      end

      def get_const_defined_on(mod, const_name)
        return mod.const_get(const_name) if const_defined_on?(mod, const_name)

        raise NameError, "uninitialized constant #{mod.name}::#{const_name}"
      end

      def constants_defined_on(mod)
        mod.constants.select { |c| const_defined_on?(mod, c) }
      end
    else
      def const_defined_on?(mod, const_name)
        mod.const_defined?(const_name, false)
      end

      def get_const_defined_on(mod, const_name)
        mod.const_get(const_name, false)
      end

      def constants_defined_on(mod)
        mod.constants(false)
      end
    end

    def recursive_const_get(const_name)
      normalize_const_name(const_name).split('::').inject(Object) do |mod, name|
        get_const_defined_on(mod, name)
      end
    end

    def recursive_const_defined?(const_name)
      parts = normalize_const_name(const_name).split('::')
      parts.inject([Object, '']) do |(mod, full_name), name|
        yield(full_name, name) if block_given? && !(Module === mod)
        return false unless const_defined_on?(mod, name)
        [get_const_defined_on(mod, name), [mod, name].join('::')]
      end
    end

    def normalize_const_name(const_name)
      #const_name.sub(/\A::/, '')
      # the \A, which means 'beginning of string' does not work in Opal/JS regex, ^ is beginning of line, which for constant names, should work OK
      const_name.sub(/^::/, '')
    end
  end
end

module ExampleGroups
  extend Support::RecursiveConstMethods

  original_constants = method(:constants)

  self.class.send(:define_method, :constants) do
    original_constants.call().dup
  end

  def self.assign_const(group)
    base_name = base_name_for(group)
    const_scope = constant_scope_for(group)
    name = disambiguate(base_name, const_scope)

    const_scope.const_set(name, group)
  end

  def self.constant_scope_for(group)
    const_scope = group.superclass
    const_scope = self if const_scope == BaseExampleGroup
    const_scope
  end

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
    # opal-rspec, mutable strings, also substituted in ^ for \A since \A is not supported in JS regex
    name = name.gsub(/^([^A-Z]|\z)/, 'Nested\1')

    name
  end

  if RUBY_VERSION == '1.9.2'
    class << self
      alias _base_name_for base_name_for

      def base_name_for(group)
        _base_name_for(group) + '_'
      end
    end
    private_class_method :_base_name_for
  end

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

class BaseExampleGroup
  @description = nil
  include MemoizedHelpers
  extend MemoizedHelpers::ClassMethods

  def self.description
    @description
  end

  def self.describe(description='default', &example_group_block)
    children = []
    subclass(self, description, &example_group_block).tap do |child|
      children << child
    end
  end

  def self.set_it_up(description)
    @description = description
  end

  def self.examples
    @examples ||= []
  end

  def self.subclass(parent, description, &example_group_block)
    subclass = Class.new(parent)
    subclass.set_it_up description
    ExampleGroups.assign_const(subclass)
    subclass.module_exec(&example_group_block) if example_group_block

    # The LetDefinitions module must be included _after_ other modules
    # to ensure that it takes precedence when there are name collisions.
    # Thus, we delay including it until after the example group block
    # has been eval'd.
    MemoizedHelpers.define_helpers_on(subclass)

    subclass
  end

  def self.example(&block)
    examples << ExampleClass.new(self, block)
    examples.last
  end

  def self.run
    examples.each do |ex|
      instance = new
      ex.run instance
    end
  end
end

class ExampleClass
  def initialize(example_group_class, example_block=nil)
    @example_group_class = example_group_class
    @example_block = example_block
  end

  def run(example_group_inst)
    RSpec.current_example = self
    example_group_inst.instance_exec self, &@example_block
    RSpec.current_example = nil
  end
end


eg = BaseExampleGroup.describe
example_yielded_to_subject = nil
# this works in both 0.8 and 0.9
# eg.let(:bah) do |something|
#   example_yielded_to_subject = something
# end

# only works on 0.9
# eg.subject(:bah) do |something|
#   puts 'subje executed'
#   # adding super gets expected error on ruby, not on opal (even on 0.9) - https://github.com/opal/opal/issues/1124
#   #super()
#   example_yielded_to_subject = something
# end

# Works on 0.8 and 0.9
eg.subject() do |something|
  puts 'subje executed'
  # adding super gets expected error on ruby, not on opal (even on 0.9) - https://github.com/opal/opal/issues/1124
  #super()
  example_yielded_to_subject = something
end

example_yielded_to_example = nil
eg.example { |e|
  subject
  example_yielded_to_example = e
}
eg.run

puts "expected #{example_yielded_to_example}, got #{example_yielded_to_subject}"
