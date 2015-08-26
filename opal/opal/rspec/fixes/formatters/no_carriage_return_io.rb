class NoCarriageReturnIO < IO
  extend IO::Writable
  
  # mimic how $stdout is built
  def initialize
    write_proc = $stdout.write_proc
  end
    
  # With Phantom, we're getting extra line breaks, so disable puts by always calling print instead
  def puts(*args)
    print *args
  end
  
  # We're deferring to stdout here, which doesn't need to be closed, but RSpec::BaseTextFormatter doesn't know that, so override this
  def closed?
    true
  end 
end
