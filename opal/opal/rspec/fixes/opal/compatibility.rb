module Opal
  module RSpec
    module Compatibility
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
      rescue Exception => _
        false
      end

      module CompatOuterScope
        module CompatSibilingModule
          def self.howdy
            true
          end
        end

        CompatStructClass = Struct.new(:param)
        class CompatStructClass
          def self.works?
            begin
              CompatSibilingModule.howdy
            rescue
              false
            end
          end
        end
      end

      # lots of Opal constant issues, see https://github.com/opal/opal/issues/1085
      def self.constant_resolution_from_struct?
        CompatOuterScope::CompatStructClass.works?
      end
    end
  end
end
