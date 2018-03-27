RSpec.configure do |c|
  c.around { |ex| Sandboxing.sandboxed { ex.run } }
end

class NullObject
  private
  def method_missing(method, *args, &block)
    # ignore
  end
end

module Sandboxing
  def self.sandboxed(&block)
    # No load path in Opal
    # orig_load_path = $LOAD_PATH.dup
    orig_config = RSpec.configuration
    orig_world  = RSpec.world
    orig_example = RSpec.current_example
    new_config = RSpec::Core::Configuration.new
    new_config.expose_dsl_globally = false
    new_config.expecting_with_rspec = true
    new_world  = RSpec::Core::World.new(new_config)
    RSpec.configuration = new_config
    RSpec.world = new_world
    object = Object.new
    object.extend(RSpec::Core::SharedExampleGroup)

    # Before https://github.com/opal/opal/commit/f73f766b261b881e6cd3256287b8afa28af99693, the stock class_exec won't work in Opal
    # (class << RSpec::Core::ExampleGroup; self; end).class_exec do
    #   alias_method :orig_run, :run
    #   def run(reporter=nil)
    #     RSpec.current_example = nil
    #     orig_run(reporter || NullObject.new)
    #   end
    # end

    RSpec::Core::ExampleGroup.class_eval do
      class << self
        alias_method :orig_run, :run

        def run(reporter=nil)
          RSpec.current_example = nil
          orig_run(reporter || NullObject.new)
        end
      end
    end

    RSpec::Mocks.with_temporary_scope do
      object.instance_exec(&block)
    end
  ensure
    # See above comment
    # (class << RSpec::Core::ExampleGroup; self; end).class_exec do
    #   remove_method :run
    #   alias_method :run, :orig_run
    #   remove_method :orig_run
    # end
    RSpec::Core::ExampleGroup.class_eval do
      class << self
        remove_method :run
        alias_method :run, :orig_run
        remove_method :orig_run
      end
    end

    RSpec.configuration = orig_config
    RSpec.world = orig_world
    RSpec.current_example = orig_example
    # No load path in Opal
    # $LOAD_PATH.replace(orig_load_path)
  end
end
