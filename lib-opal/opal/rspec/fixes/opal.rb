require 'opal/platform'
require 'opal-parser'
require 'thread'
require 'corelib/marshal'
require 'ruby2_keywords'

class IO
  def closed?
    true
  end
end

Errno::ENOTDIR = Class.new(SystemCallError)

require 'nodejs' if OPAL_PLATFORM == 'nodejs'

module Kernel
  def trap(sig, &block)
  end
end

require 'js'

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

      # not currently needed but is referenced in space.rb fix, https://github.com/opal/opal/issues/1279 - fixed in 0.10
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
      rescue Exception => _
        false
      end
    end
  end
end

