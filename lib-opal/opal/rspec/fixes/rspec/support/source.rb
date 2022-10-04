require 'js'

module RSpec
  module Support
    class Source
      # Allow to use embedded sources
      def self.from_file(path)
        source = JS[:Opal].JS[:file_sources].JS[path]
        source ||= JS[:Opal].JS[:file_sources].JS["./#{path}"]
        source ||= File.read(path)
        new(source, path)
      end
    end
  end
end
