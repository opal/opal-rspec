unless Opal::RSpec::Compatibility.module_subclass_works?
  class Module
    def self.allocate
      %x{
        var module;
        module = Opal.module_allocate(self);
        Opal.create_scope(Opal.Module.$$scope, module, null);
        return module;
      }
    end
  end

  %x{
    // we're not inside runtime.js, so need to do this
    var Module = Opal.Module;
    var $hasOwn = Opal.hasOwnProperty;

    Opal.module = function(base, name) {
      var module;

      if (!base.$$is_class && !base.$$is_module) {
        base = base.$$class;
      }

      if ($hasOwn.call(base.$$scope, name)) {
        module = base.$$scope[name];

        if (!module.$$is_module && module !== _Object) {
          throw Opal.TypeError.$new(name + " is not a module");
        }
      }
      else {
        module = Opal.module_allocate(Module);
        Opal.create_scope(base.$$scope, module, name);
      }

      return module;
    };

   Opal.module_allocate = function(superclass) {
    var mtor = function() {};
    mtor.prototype = superclass.$$alloc.prototype;

    function module_constructor() {}
    module_constructor.prototype = new mtor();

    var module = new module_constructor();
    var module_prototype = {};

    // @property $$id Each class is assigned a unique `id` that helps
    //                comparation and implementation of `#object_id`
    module.$$id = Opal.uid();

    // Set the display name of the singleton prototype holder
    module_constructor.displayName = "#<Class:#<Module:"+module.$$id+">>"

    // @property $$proto This is the prototype on which methods will be defined
    module.$$proto = module_prototype;

    // @property constructor
    //   keeps a ref to the constructor, but apparently the
    //   constructor is already set on:
    //
    //      `var module = new constructor` is called.
    //
    //   Maybe there are some browsers not abiding (IE6?)
    module.constructor = module_constructor;

    // @property $$is_module Clearly mark this as a module
    module.$$is_module = true;
    module.$$class     = Module;

    // @property $$super
    //   the superclass, doesn't get changed by module inclusions
    module.$$super = superclass;

    // @property $$parent
    //   direct parent class or module
    //   starts with the superclass, after module inclusion is
    //   the last included module
    module.$$parent = superclass;

    // @property $$inc included modules
    module.$$inc = [];

    // mark the object as a module
    module.$$is_module = true;

    // initialize dependency tracking
    module.$$dep = [];

    // initialize the name with nil
    module.$$name = nil;

    // @property $$cvars class variables defined in the current module
    module.$$cvars = {};

    return module;
  };

  }
end
