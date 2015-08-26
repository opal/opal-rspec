# Random causes problems that can lock up a browser (see README) 
class ::RSpec::Core::Ordering::Random
  def initialize(configuration)
    `console.warn("Random order is not currently supported by opal-rspec, using default order.")`
  end
  
  # Identity is usually the default, so borrowing its implementation, this forces 'accidental' random usage down that path    
  def order(items)
    items
  end
end
