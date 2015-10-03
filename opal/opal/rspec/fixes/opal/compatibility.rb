module Opal
  module RSpec
    module Compatibility
      # https://github.com/opal/opal/commit/78016aa11955e4cff3d6bbf06f1222d40b03a9e6, fixed in Opal 0.9
      def self.clones_singleton_methods?
        obj = Object.new
        def obj.special() :the_one end
        clone = obj.clone
        clone.respond_to?(:special) && clone.special == :the_one
      end
    end
  end
end
