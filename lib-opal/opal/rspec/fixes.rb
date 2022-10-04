require 'encoding' unless Object.const_defined? :Encoding
# Thread usage in core.rb
require 'thread'
require_relative 'fixes/diff-lcs'
require_relative 'fixes/rspec'
require_relative 'fixes/opal'
