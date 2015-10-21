class ::Dir
  def self.[](index)
    []
  end
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
