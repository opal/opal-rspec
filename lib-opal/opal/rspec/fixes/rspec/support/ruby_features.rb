module RSpec
  module Support
    # Temporary implementation
    def self.require_rspec_support(what)
      require "rspec/support/#{what}"
    end
  end
end

require 'rspec/support/ruby_features'

module RSpec
  module Support
    module RubyFeatures
      module_function

      def ripper_supported?
        false
      end
    end
  end
end
