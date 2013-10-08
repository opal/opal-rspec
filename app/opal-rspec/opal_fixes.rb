class Module
  alias module_exec module_eval
end

module Kernel
  alias private_methods methods
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
