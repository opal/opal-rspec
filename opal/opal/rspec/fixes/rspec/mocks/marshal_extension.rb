# Not currently supporting Marshal stuff on Opal (although there is an unvetted implementation there)
module RSpec
  module Mocks
    # Support for `patch_marshal_to_support_partial_doubles` configuration.
    #
    # @private
    class MarshalExtension
      def self.patch!
      end

      def self.unpatch!
      end
    end
  end
end
