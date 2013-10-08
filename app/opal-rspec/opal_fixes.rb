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

  def dup
    raise "duped module #{self}"
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
end

module Kernel
  alias private_methods methods

  def caller
    []
  end
end

module Kernel
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

class Hash
  def store(key, val)
    self[key] = val
  end
end

class Regexp
  def self.union(*parts)
    `new RegExp(parts.join(''))`
  end
end

module Kernel
  alias_method :srand, :rand
end

%x{
  Opal.donate = function(klass, defined, indirect) {
    var methods = klass._methods, included_in = klass.__dep__;

    if (!methods) { return; }

    // if (!indirect) {
      klass._methods = methods.concat(defined);
    // }

    if (included_in) {
      for (var i = 0, length = included_in.length; i < length; i++) {
        var includee = included_in[i];
        var dest = includee._proto;

        for (var j = 0, jj = defined.length; j < jj; j++) {
          var method = defined[j];
          dest[method] = klass._proto[method];
        }

        if (includee.__dep__) {
          Opal.donate(includee, defined, true);
        }
      }
    }
  };
}
