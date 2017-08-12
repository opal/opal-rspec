require 'stringio'

module Opal
  module RSpec
    class NoopFlushStringIO < StringIO
      # make printer happy
      def flush
      end
    end
  end
end
