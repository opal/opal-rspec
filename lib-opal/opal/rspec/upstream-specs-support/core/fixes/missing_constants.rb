def Dir.[](_glob)
  []
end

module Aruba
  module Api
  end
end

# None of this is supported in Opal
module RSpec::Support::ShellOut
end

module MathnIntegrationSupport
  def with_mathn_loaded
    yield
  end
end

class Shellwords
  def self.split(string)
    string.split(/\s+/)
  end
end

class OptionParser
  InvalidOption = Class.new(StandardError)
  def parse!(_opts)
  end
end

