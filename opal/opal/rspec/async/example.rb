class ::RSpec::Core::Example
  def with_around_example_hooks(&block)
    if around_example_hooks.empty?
      yield
    else
      # Async examples will return a promise for the around hook to use after calling example.run
      # Sync examples don't. Rather than monkey patch that method, which is more key to RSpec, monkey patching this, which is a smaller method
      use_block = if self.is_a? Opal::RSpec::AsyncExample
        block
      else
        lambda do
          block.call          
          Promise.new.resolve
        end
      end
      @example_group_class.hooks.run(:around, :example, self, Procsy.new(self, &use_block))
    end
  rescue Exception => e
    set_exception(e, "in an `around(:example)` hook")
  end
end
