class ::RSpec::Core::Configuration
  # This needs to be implemented if/when we allow the Opal side to decide what files to run
  def files_or_directories_to_run=(*files)
    @files_or_directories_to_run = []
    @files_to_run = nil
  end

  def requires=(paths)
    # can't change requires @ this stage, this method calls RubyProject which will crash on Opal
  end

  # Do not support persisting this right now
  def last_run_statuses
    Hash.new(UNKNOWN_STATUS)
  end

  def configure_example(example)
    singleton_group = example.example_group_instance.singleton_class

    # We replace the metadata so that SharedExampleGroupModule#included
    # has access to the example's metadata[:location].
    singleton_group.with_replaced_metadata(example.metadata) do
      modules = @include_modules.items_for(example.metadata)
      modules.each do |mod|
        safe_include(mod, example.example_group_instance.singleton_class)
      end

      # on Opal, this causes memoization/let helpers to break if a module is included
      # https://github.com/rspec/rspec-core/pull/1912
      # MemoizedHelpers.define_helpers_on(singleton_group) unless modules.empty?
    end
  end
end
