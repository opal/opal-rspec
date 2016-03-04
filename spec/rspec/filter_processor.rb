module Opal
  module RSpec
    module OpalVersionStuff
      def arity_checking_working?
        at_least_opal_0_10?
      end

      def at_least_opal_0_10?
        greater_equal_than_version?('0.10')
      end

      def at_least_opal_0_9?
        greater_equal_than_version?('0.9')
      end

      def greater_equal_than_version?(version)
        # it's ok if we have a pre-release version
        Gem::Version.new(Opal::VERSION) >= Gem::Version.new("#{version}.0.a")
      end
    end

    class FilterProcessor
      attr_reader :all_filters
      attr_accessor :filename

      include OpalVersionStuff

      class GuardCheck
        attr_reader :opal_version

        include Opal::RSpec::OpalVersionStuff

        def initialize(current_filters, opal_version)
          @current_filters = current_filters
          @opal_version = opal_version
        end

        def unless(&block)
          result = instance_eval(&block)
          remove_filter if result
        end

        def if(&block)
          result = instance_eval(&block)
          remove_filter unless result
        end

        private

        def remove_filter
          @current_filters.pop
          nil
        end
      end

      def initialize
        @all_filters = []
        @current_title = nil
        @current_filters = []
      end

      def rspec_filter(title)
        @current_filters = []
        @current_title = title
        yield
        @all_filters += @current_filters.map do |filter|
          filter.merge({ title: @current_title })
        end
      end

      def filter(value)
        call_info = caller[0]
        line_number = /.*:(\d+)/.match(call_info).captures[0]
        @current_filters << {
          filename: filename,
          line_number: line_number,
          exclusion: value
        }
        GuardCheck.new(@current_filters, opal_version)
      end

      private

      def opal_version
        Opal::VERSION
      end
    end
  end
end
