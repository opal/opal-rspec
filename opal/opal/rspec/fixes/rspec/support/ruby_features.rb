module RSpec
  module Support
    module OS
      module_function

      def windows?
        !!(RbConfig::CONFIG['host_os'] =~ /cygwin|mswin|mingw|bccwin|wince|emx/)
      end

      def windows_file_path?
        ::File::ALT_SEPARATOR == '\\'
      end
    end

    module Ruby
      module_function

      def jruby?
        false
      end

      def rbx?
        false
      end

      def non_mri?
        true
      end

      def mri?
        false
      end
    end

    module RubyFeatures
      module_function

      def required_kw_args_supported?
        true
      end

      def kw_args_supported?
        true
      end

      def supports_rebinding_module_methods?
        true
      end

      def optional_and_splat_args_supported?
        Method.method_defined?(:parameters)
      end

      def caller_locations_supported?
        respond_to?(:caller_locations, true)
      end

      if Exception.method_defined?(:cause)
        def supports_exception_cause?
          true
        end
      else
        def supports_exception_cause?
          false
        end
      end

      def ripper_supported?
        false
      end

      def module_prepends_supported?
        Module.method_defined?(:prepend) || Module.private_method_defined?(:prepend)
      end
    end
  end
end
