module RSpec
  module Core
    module Formatters
      # @private
      class SnippetExtractor
        def self.source_from_file(path)
          # Don't check for file existence, we may still have its embedded source
          # raise NoSuchFileError unless File.exist?(path)
          RSpec.world.source_from_file(path)
        rescue Errno::ENOENT, Errno::ENAMETOOLONG
          # But if we really don't, well...
          raise NoSuchFileError
        end
      end
    end
  end
end
