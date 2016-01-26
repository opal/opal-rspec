module Opal
  module RSpec
    module Compatibility
      module ModuleCase
      end

      module ModuleCase2
        include ModuleCase
      end

      class ModuleCase3
        include ModuleCase2
      end

      # not currently needed but is referenced in space.rb fix, https://github.com/opal/opal/issues/1279 - still not fixed
      def self.module_case_works_right?
        instance = ModuleCase3.new
        ModuleCase === instance && instance.kind_of?(ModuleCase)
      end

      module MultModSuper1
        def stuff
          :howdy
        end
      end

      module MultModSuper2
        def stuff
          super
        end
      end

      module MultModSuper3
        include MultModSuper1
        include MultModSuper2
      end

      class MultModSuperClass
        include MultModSuper3
      end

      # https://github.com/opal/opal/issues/568 - still not fixed
      def self.multiple_module_include_super_works_right?
        MultModSuperClass.new.stuff == :howdy
      rescue
        false
      end

      # MRI does this properly, not yet fixed in Opal, https://github.com/opal/opal/issues/1278
      def self.lambda_zero_arg_throws_arg_error?
        !(lambda { 3 } === lambda { 4 })
      rescue
        true
      end
    end
  end
end
