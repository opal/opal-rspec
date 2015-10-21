module Foo
  def howdy
    puts 'howdy'
  end
end

class Stuff
  include Foo
end

# This approach fails on opal-master
# module Foo
#   undef howdy
# end
#
# Stuff.new.howdy

# This approach also fails on opal-master
Foo.send(:remove_method, :howdy)
Stuff.new.howdy
