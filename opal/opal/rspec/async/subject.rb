class ::RSpec::Core::ExampleGroup
  # TODO: Move this to another file
  def self.async_it(the_subject=nil, &block)
    wrapped_block = lambda do
      promise = the_subject || subject
      promise.then do |resolved_subject|
        __memoized[:subject] = resolved_subject
        self.instance_eval(&block)
      end
    end
    async &wrapped_block
  end  
end
