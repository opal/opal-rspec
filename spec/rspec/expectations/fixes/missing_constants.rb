ComplexStruct = Struct.new(:args)

def Complex(*args)
  ComplexStruct.new(args)
end

# In Opal 0.9
unless Object.const_defined?(:Math) && Object.const_defined?(:PI)
  module Math
    PI = `Math.PI`
  end
end
