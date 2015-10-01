# https://github.com/opal/opal/issues/1079
class Class
  def to_s
    name || "#<#{`self.$$is_mod ? 'Module' : 'Class'`}:0x#{__id__.to_s(16)}>"
  end
end
