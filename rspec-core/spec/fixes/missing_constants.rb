def Dir.[](_glob)
  []
end

def Dir.mktmpdir(*)
  ''
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

module Open3
end

module DRb
  class DRbServerNotFound < StandardError; end unless defined? DRbServerNotFound

  def self.current_server
    raise DRbServerNotFound
  end

  def self.stop_service
  end
end
