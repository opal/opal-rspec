# Opal does not support ObjectSpace, so force object __id__'s
class RSpec::Mocks::Space
  def id_for(object)
    object.__id__
  end
end
