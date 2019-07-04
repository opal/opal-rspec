module Opal
  module RSpec
    class DocumentIO < IO
      include IO::Writable

      def initialize
        `document.open()`
      end

      def close
        @closed = true
        `document.close()`
      end

      def write(html)
        if @closed
          `console.error(#{"DOC closed, can't write #{html}" })`
        else
          `document.write(#{html})`
        end
      end

      def flush
      end
    end
  end
end
