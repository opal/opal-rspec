module RSpec::Core::Pending
  alias_method :sync_skip, :skip
  alias_method :sync_pending, :pending
  
  def skip(message=nil)
    # ugly, but avoids having to duplicate the original method, so more maintainable
    begin
      sync_skip message
    rescue SkipDeclaredInExample => e
      example = RSpec.current_example
      example.notify_async_exception e
      example.notify_async_completed   
    end
  end
  
  def pending(message=nil)
    sync_pending message
    example = RSpec.current_example
    example.notify_async_completed
  end
end
