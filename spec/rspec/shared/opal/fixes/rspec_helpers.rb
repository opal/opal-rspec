# the safety method is defined in helper_methods and uses threads
module RSpecHelpers
  def safely
    yield
  end
end
