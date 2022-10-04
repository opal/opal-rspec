require 'opal-replutils'

module RSpec
  module Core
    module Formatters
      # @private
      # Provides terminal syntax highlighting of code snippets
      # when coderay is available.
      class SyntaxHighlighter
        # A poor-man highlighter
        def highlight(lines)
          REPLUtils::ColorPrinter.colorize(lines.join("\n")).split("\n")
        end
      end
    end
  end
end
