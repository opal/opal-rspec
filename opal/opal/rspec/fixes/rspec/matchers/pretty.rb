# Opal does not support mutable strings
module RSpec
  module Matchers
    module Pretty
      def underscore(camel_cased_word)
        word = camel_cased_word.to_s
        word = word.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
        word = word.gsub(/([a-z\d])([A-Z])/,'\1_\2')
        word = word.tr("-", "_")
        word = word.downcase
        word
      end
    end
  end
end
