class ::RSpec::Core::Example  
  def core_block_run
    example_promise = Promise.value(@example_group_instance.instance_exec(self, &@example_block))
    example_promise.then do |result|
      result      
    end.rescue do |ex|
      ex ||= Exception.new 'Async promise failed for unspecified reason'
      ex = Exception.new ex unless ex.kind_of?(Exception)
      ex
    end
  end
  
  def resolve_subject
    if example_group_instance.respond_to? :subject and example_group_instance.subject.is_a?(Promise)
      example_group_instance.subject.then do |resolved_subject|
        # This is a private method, but we're using Opal
        example_group_instance.__memoized[:subject] = resolved_subject        
      end
    else
      Promise.value
    end
  end
  
  def run_after_example
    @example_group_class.hooks.run(:after, :example, self).then do
      verify_mocks
      assign_generated_description if RSpec.configuration.expecting_with_rspec?      
    end.rescue do |e|
      set_exception(e, "in an `after(:example)` hook")
    end.ensure do
      @example_group_instance.teardown_mocks_for_rspec
    end    
  end
  
  # TODO: Fix this
  def with_around_example_hooks
    yield
  end 
  
  def run(example_group_instance, reporter)
    @example_group_instance = example_group_instance
    RSpec.current_example = self

    start(reporter)
    Pending.mark_pending!(self, pending) if pending?

    Promise.value.then do
      Promise.value.then do
        if skipped?
          Pending.mark_pending! self, skip
        elsif !RSpec.configuration.dry_run?
          with_around_example_hooks do
            Promise.value.then do
              run_before_example.then do
                resolve_subject
              end.then do
                core_block_run
              end.then do
                if pending?
                  Pending.mark_fixed! self

                  raise Pending::PendingExampleFixedError,
                        'Expected example to fail since it is pending, but it passed.',
                        [location]
                end
              end
            end.rescue do |e|
              puts "got exception in run #{e}"
              # no-op, required metadata has already been set by the `skip`
              # method.              
              unless e.is_a? Pending::SkipDeclaredInExample
                set_exception(e)
              end
            end.ensure do
              run_after_example
            end            
          end
        end
      end.rescue do |e|
        set_exception(e)
      end.ensure do
        @example_group_instance.instance_variables.each do |ivar|
          @example_group_instance.instance_variable_set(ivar, nil)
        end
        @example_group_instance = nil
      end      
    end.then do
      finish(reporter)
    end.ensure do
      RSpec.current_example = nil
    end
  end  
end
