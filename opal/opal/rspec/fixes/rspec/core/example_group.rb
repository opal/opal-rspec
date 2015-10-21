unless Opal::RSpec::Compatibility.class_descendant_of_self_fixed?
  class ::RSpec::Core::ExampleGroup
    def self.parent_groups
      # https://github.com/opal/opal/issues/1077, fixed in Opal 0.9
      # @parent_groups ||= ancestors.select { |a| a < RSpec::Core::ExampleGroup }
      @parent_groups ||= ancestors.select { |a| a < RSpec::Core::ExampleGroup and a != RSpec::Core::ExampleGroup }
    end
  end
end
