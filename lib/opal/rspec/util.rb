module ::Opal
  module RSpec
    def self.load_namespaced(file, mod)
      if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.1")
        load file, mod
      else
        str = ""
        str += "module ::#{mod.name};"
        str += File.read(file)
        str += ";end"
        eval(str)
      end
    end
  end
end
