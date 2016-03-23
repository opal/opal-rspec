unless Opal::RSpec::Compatibility.block_method_weirdness_works_ok?
  class ::RSpec::Core::World
    # https://github.com/opal/opal/issues/1173
    def all_examples
      #FlatMap.flat_map(all_example_groups) { |g| g.examples }
      example_groups = all_example_groups
      FlatMap.flat_map(example_groups) { |g| g.examples }
    end
  end
end
