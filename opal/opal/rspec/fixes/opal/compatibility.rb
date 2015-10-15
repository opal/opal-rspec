module Opal
  module RSpec
    module Compatibility
      # https://github.com/opal/opal/commit/78016aa11955e4cff3d6bbf06f1222d40b03a9e6, fixed in Opal 0.9
      def self.clones_singleton_methods?
        obj = Object.new

        def obj.special()
          :the_one
        end

        clone = obj.clone
        clone.respond_to?(:special) && clone.special == :the_one
      end

      # https://github.com/opal/opal/pull/1104, fixed in Opal 0.9
      def self.pp_uses_stdout_default?
        require 'stringio'
        require 'pp'

        stdout = $stdout
        $stdout = StringIO.new
        msg = 'opal-rspec - checking pp/pretty print features'
        PP.pp msg
        $stdout.string == "\"#{msg}\"\n"
      ensure
        $stdout = stdout
      end

      # https://github.com/opal/opal/issues/1079, fixed in Opal 0.9
      def self.full_class_names?
        Opal::RSpec::Compatibility.to_s == 'Opal::RSpec::Compatibility'
      end

      # https://github.com/opal/opal/pull/1123, SHOULD be fixed in Opal 0.9
      def self.is_struct_hash_correct?
        s = Struct.new(:id)
        s.new(1) == s.new(1)
      end

      # https://github.com/opal/opal/issues/1080, fixed in Opal 0.9
      def self.is_constants_a_clone?
        mod = Opal::RSpec::Compatibility
        `#{mod.constants} !== #{mod.constants}`
      end

      # https://github.com/opal/opal/issues/1077, fixed in Opal 0.9
      def self.class_descendant_of_self_fixed?
        !(String < String)
      end

      # https://github.com/opal/opal/issues/1090, fixed in Opal 0.9
      def self.and_works_with_lhs_nil?
        value = nil
        (value && nil) == nil
      end

      # https://github.com/opal/opal/issues/858
      def self.is_set_coerced_to_array?
        require 'set'

        obj = Object.new

        def obj.splat(*data)
          return data[0]
        end

        obj.splat(*Set.new(Set.new([:foo, :bar]))) == :foo
      end

      # https://github.com/opal/opal/pull/1117, status pending
      def self.fail_raise_matches_mri?
        ex = nil
        %x{
          try {
            #{fail}
          }
          catch(e) {
            #{ex} = e;
          }
        }
        ex.is_a? RuntimeError
      end

      TEST_CLASS = Class.new do
        class ClassWithinClassNewWorks
        end

        def self.does_class_exist?
          Compatibility.const_defined? :ClassWithinClassNewWorks
        end
      end

      # https://github.com/opal/opal/issues/1110, fixed in Opal 0.9
      def self.class_within_class_new_works?
        TEST_CLASS.does_class_exist?
      end

      # Fixed in Opal 0.9
      def self.undef_within_exec_works?
        klass = Class.new do
          def bar
          end
        end

        klass.class_exec do
          undef bar
        end

        !klass.new.respond_to? :bar
      end

      # https://github.com/opal/opal/pull/1129
      def self.multiline_regex_works?
        /foo.bar/m.match("foo\nbar").to_a == ["foo\nbar"]
      end

      # https://github.com/opal/opal/pull/1129
      def self.empty_regex_works?
        empty = //
        begin
          empty.options == 0 && empty.match('foo').to_s == ''
        rescue
          false
        end
      end

      # https://github.com/opal/opal/pull/1129
      def self.regex_case_compare_works?
        begin
          (/abc/ === nil) == false && (/abc/ === /abc/) == false
        rescue
          false
        end
      end

      class ConstTest
      end

      module ModuleConstTest
      end

      # https://github.com/opal/opal/issues/1085
      def self.constant_resolution_works_right?
        begin
          ModuleConstTest::ConstTest.new
          false
        rescue
          true
        end
      end

      # https://github.com/opal/opal/pull/1134
      def self.exception_inspect_matches?
        Exception.new.inspect == '#<Exception: Exception>'
      end

      # https://github.com/opal/opal/pull/1151, should be fixed in Opal 0.9
      def self.exception_exception_method_works?
        Exception.respond_to?(:exception) && Exception.exception.is_a?(Exception)
      end

      # https://github.com/opal/opal/pull/1135
      def self.ostruct_works_right?
        require 'ostruct'

        s = OpenStruct.new(:exist? => true)
        s.respond_to? :exist?
      end

      module ModuleCase
      end

      module ModuleCase2
        include ModuleCase
      end

      class ModuleCase3
        include ModuleCase2
      end

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

      def self.multiple_module_include_super_works_right?
        MultModSuperClass.new.stuff == :howdy
      rescue
        false
      end

      # https://github.com/opal/opal/pull/1152
      def self.set_has_superset?
        require 'set'
        Set.new.respond_to?(:superset?)
      end
    end
  end
end
