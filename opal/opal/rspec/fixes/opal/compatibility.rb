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
        PP.pp 'pp check'
        $stdout.string == "\"pp check\"\n"
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
    end
  end
end
