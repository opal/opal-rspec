class Module
  alias module_exec module_eval
  alias class_exec module_exec

  def private_class_method(name)
    `self['$' + name] || nil`
  end

  def self.new(&block)
    %x{
      function AnonModule(){}
      var klass = Opal.boot(Module, AnonModule);
      klass._name = nil;
      klass._scope = Module._scope;
      klass._klass = Module;
      klass.__dep__ = [];

      if (block !== nil) {
        var block_self = block._s;
        block._s = null;
        block.call(klass);
        block._s = block_self;
      }

      return klass;
    }
  end

  def <(other)
    %x{
      var working = self;

      while (working) {
        if (working === other) {
          return true;
        }

        working = working.__parent;
      }

      return false;
    }
  end
end

class Class
  def self.new(sup = Object, &block)
    %x{
      function AnonClass(){};
      var klass   = Opal.boot(sup, AnonClass)
      klass._name = nil;
      klass._scope = sup._scope;
      klass.__parent = sup;

      sup.$inherited(klass);

      if (block !== nil) {
        var block_self = block._s;
        block._s = null;
        block.call(klass);
        block._s = block_self;
      }

      return klass;
    }
  end
end

class Hash
  def clone
    %x{
      var result = new self._klass._alloc();

      result.map = {}; result.keys = [];

      var map    = #{self}.map,
          map2   = result.map,
          keys2  = result.keys;

      for (var i = 0, length = #{self}.keys.length; i < length; i++) {
        keys2.push(#{self}.keys[i]);
        map2[#{self}.keys[i]] = map[#{self}.keys[i]];
      }

      return result;
    }
  end

  alias_method :dup, :clone

  alias_method :store, :[]=
end

module Kernel
  alias private_methods methods

  def caller
    []
  end

  def instance_variables
    %x{
      var result = [];

      for (var name in #{self}) {
        if (name.charAt(0) !== '$') {
          result.push('@' + name);
        }
      }

      return result;
    }
  end

  alias_method :srand, :rand
end

class File
  SEPARATOR = '/'

  def self.expand_path(*)
    ''
  end
end

class Dir
  def self.getwd
    '.'
  end
end

class Regexp
  def self.union(*parts)
    `new RegExp(parts.join(''))`
  end
end

# Rspec makes examples thread safe....
class Thread
  def self.current
    @current ||= self.new
  end

  def initialize
    @hash = {}
  end

  def [](key)
    @hash[key]
  end

  def []=(key, val)
    @hash[key] = val
  end
end

