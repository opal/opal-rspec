ComplexStruct = Struct.new(:args)

def Complex(*args)
  ComplexStruct.new(args)
end
