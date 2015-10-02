module Opal
  def self.valid_method_name?(method_name)
    method_name = Opal.coerce_to!(method_name, String, :to_str)

    `/^[a-zA-Z_][a-zA-Z0-9_]*?$/.test(method_name)`
  end
end

# Struct was rewritten in Opal 0.9
# https://github.com/opal/opal/blob/1a33f23fdb4b07ff07b89f8077da060f1fdb635c/opal/corelib/struct.rb
# Then a hash fix for Struct (which keeps deprectation formatter from grouping properly) was submitted in https://github.com/opal/opal/pull/1123
# For simplicity's sake, cut and pasted entire Opal 0.9 struct class here

# Native monkey patches struct's initializer, so get it in first
require 'native'

class Struct
  include Enumerable

  def self.new(name = undefined, *args, &block)
    return super unless self == Struct

    if name[0] == name[0].upcase
      Struct.const_set(name, new(*args))
    else
      args.unshift name

      Class.new(self) {
        args.each { |arg| define_struct_attribute arg }

        instance_eval(&block) if block

        class << self
          def new(*args)
            instance = allocate
            `#{instance}.$$data = {};`
            instance.initialize(*args)
            instance
          end

          alias [] new
        end
      }
    end
  end

  def self.define_struct_attribute(name)
    if self == Struct
      raise ArgumentError, 'you cannot define attributes to the Struct class'
    end

    members << name

    if Opal.valid_method_name?(name)
      define_method name do
        self[name]
      end

      define_method "#{name}=" do |value|
        self[name] = value
      end
    end
  end

  def self.members
    if self == Struct
      raise ArgumentError, 'the Struct class has no members'
    end

    @members ||= []
  end

  def self.inherited(klass)
    members = @members

    klass.instance_eval {
      @members = members
    }
  end

  def initialize(*args)
    members.each_with_index { |name, index|
      self[name] = args[index]
    }
  end

  def members
    self.class.members
  end

  def [](name)
    if Integer === name
      raise IndexError, "offset #{name} too small for struct(size:#{members.size})" if name < -members.size
      raise IndexError, "offset #{name} too large for struct(size:#{members.size})" if name >= members.size

      name = members[name]
    elsif String === name
      raise NameError, "no member '#{name}' in struct" unless members.include?(name.to_sym)
    else
      raise TypeError, "no implicit conversion of #{name.class} into Integer"
    end

    name = Opal.coerce_to!(name, String, :to_str)
    `self.$$data[name]`
  end

  def []=(name, value)
    if Integer === name
      raise IndexError, "offset #{name} too small for struct(size:#{members.size})" if name < -members.size
      raise IndexError, "offset #{name} too large for struct(size:#{members.size})" if name >= members.size

      name = members[name]
    elsif String === name
      raise NameError, "no member '#{name}' in struct" unless members.include?(name.to_sym)
    else
      raise TypeError, "no implicit conversion of #{name.class} into Integer"
    end

    name = Opal.coerce_to!(name, String, :to_str)
    `self.$$data[name] = value`
  end

  def ==(other)
    return false unless other.instance_of?(self.class)

    %x{
        var recursed1 = {}, recursed2 = {};

        function _eqeq(struct, other) {
          var key, a, b;

          recursed1[#{`struct`.__id__}] = true;
          recursed2[#{`other`.__id__}] = true;

          for (key in struct.$$data) {
            a = struct.$$data[key];
            b = other.$$data[key];

            if (#{Struct === `a`}) {
              if (!recursed1.hasOwnProperty(#{`a`.__id__}) || !recursed2.hasOwnProperty(#{`b`.__id__})) {
                if (!_eqeq(a, b)) {
                  return false;
                }
              }
            } else {
              if (!#{`a` == `b`}) {
                return false;
              }
            }
          }

          return true;
        }

        return _eqeq(self, other);
      }
  end

  def hash
    Hash.new(`self.$$data`).hash
  end

  def eql?(other)
    return false unless other.instance_of?(self.class)

    %x{
        var recursed1 = {}, recursed2 = {};

        function _eqeq(struct, other) {
          var key, a, b;

          recursed1[#{`struct`.__id__}] = true;
          recursed2[#{`other`.__id__}] = true;

          for (key in struct.$$data) {
            a = struct.$$data[key];
            b = other.$$data[key];

            if (#{Struct === `a`}) {
              if (!recursed1.hasOwnProperty(#{`a`.__id__}) || !recursed2.hasOwnProperty(#{`b`.__id__})) {
                if (!_eqeq(a, b)) {
                  return false;
                }
              }
            } else {
              if (!#{`a`.eql?(`b`)}) {
                return false;
              }
            }
          }

          return true;
        }

        return _eqeq(self, other);
      }
  end

  def each
    return enum_for(:each) { self.size } unless block_given?

    members.each { |name| yield self[name] }
    self
  end

  def each_pair
    return enum_for(:each_pair) { self.size } unless block_given?

    members.each { |name| yield [name, self[name]] }
    self
  end

  def length
    members.length
  end

  alias size length

  def to_a
    members.map { |name| self[name] }
  end

  alias values to_a

  def inspect
    result = "#<struct "

    if self.class == Struct
      result += "#{self.class} "
    end

    result += each_pair.map { |name, value|
      "#{name}=#{value.inspect}"
    }.join ", "

    result += ">"

    result
  end

  alias to_s inspect

  def to_h
    members.inject({}) { |h, name| h[name] = self[name]; h }
  end

  def values_at(*args)
    args = args.map { |arg| `arg.$$is_range ? #{arg.to_a} : arg` }.flatten
    %x{
        var result = [];
        for (var i = 0, len = args.length; i < len; i++) {
          if (!args[i].$$is_number) {
            #{raise TypeError, "no implicit conversion of #{`args[i]`.class} into Integer"}
          }
          result.push(#{self[`args[i]`]});
        }
        return result;
      }
  end
end
