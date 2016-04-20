module Opal
  module RSpec
    module AsyncHelpers
      module ClassMethods
        def async(desc, *args, &block)
          options = ::RSpec::Core::Metadata.build_hash_from(args)
          options.update(:skip => ::RSpec::Core::Pending::NOT_YET_IMPLEMENTED) unless block

          examples << Opal::RSpec::LegacyAsyncExample.new(self, desc, options, block)
          examples.last
        end
      end

      attr_accessor :legacy_promise

      def self.included(base)
        base.extend ClassMethods
      end

      # Use {#async} instead.
      #
      # @deprecated
      def run_async(&block)
        async(&block)
      end

      def async(&block)
        begin
          instance_eval &block
          legacy_promise.resolve
        rescue Exception => e
          legacy_promise.reject e
        end
      end
    end
  end
end

class Opal::RSpec::LegacyAsyncExample < ::RSpec::Core::Example
  def initialize(example_group_class, description, user_metadata, example_block=nil)
    legacy_promise_ex_block = lambda do |example|
      self.legacy_promise = Promise.new
      instance_exec(example, &example_block)
      self.legacy_promise
    end

    super example_group_class, description, user_metadata, legacy_promise_ex_block
  end
end
