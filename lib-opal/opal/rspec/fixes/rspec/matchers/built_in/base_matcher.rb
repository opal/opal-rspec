require 'rspec/matchers/built_in/base_matcher'

module RSpec
  module Matchers
    module BuiltIn
      class BaseMatcher
        # activesupport/lib/active_support/inflector/methods.rb, line 48
        # mutable strings fixed for opal
        def self.underscore(camel_cased_word)
          word = camel_cased_word.to_s.dup
          word = word.gsub(/::/, '/')
          word = word.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          word = word.gsub(/([a-z\d])([A-Z])/, '\1_\2')
          word = word.tr("-", "_")
          word.downcase
        end

        def description
          desc = EnglishPhrasing.split_words(self.class.matcher_name)
          desc += EnglishPhrasing.list(@expected) if defined?(@expected)
          desc
        end
      end
    end
  end
end
