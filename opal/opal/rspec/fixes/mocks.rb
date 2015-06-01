# Opal does not support ObjectSpace, so force object __id__'s
class RSpec::Mocks::Space
  def id_for(object)
    object.__id__
  end
end

# Buggy under Opal?
class RSpec::Mocks::MethodDouble
  def save_original_method!
    @original_method ||= @method_stasher.original_method
  end
end
