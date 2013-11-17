class User
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def admin?
    @name == 'Bob'
  end
end
