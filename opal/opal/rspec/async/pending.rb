module RSpec::Core::Pending
  alias_method :sync_skip, :skip
  
  def skip(message=nil)
    # ugly, but avoids having to duplicate the original method, so more maintainable
    begin
      sync_skip message
    rescue SkipDeclaredInExample => e
      @@async_exceptions << e
      example = RSpec.current_example
      example.notify_async_completed if example.is_a? Opal::RSpec::AsyncExample
    end
  end
end
