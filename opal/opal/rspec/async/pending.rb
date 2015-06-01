module RSpec::Core::Pending
  alias_method :sync_skip, :skip
  
  def skip(message=nil)
    # ugly, but avoids having to duplicate the original method, so more maintainable
    begin
      sync_skip message
    rescue SkipDeclaredInExample => e
      @@async_exceptions << e
    end
  end
end
