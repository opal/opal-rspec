# Random causes problems that can lock up a browser (see README) 
module ::RSpec::Core::Ordering
  # Identity is usually the default, so borrowing its implementation, this forces 'accidental' random usage down that path
  class Random
    def initialize(configuration)
      `console.warn("Random order is not currently supported by opal-rspec, using default order.")`
    end
    
    def order(items)
      items
    end
  end  
end
