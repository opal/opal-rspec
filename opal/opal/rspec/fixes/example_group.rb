class ::RSpec::Core::ExampleGroup
  def self.parent_groups
    # https://github.com/opal/opal/issues/1077
    # @parent_groups ||= ancestors.select { |a| a < RSpec::Core::ExampleGroup }
    @parent_groups ||= ancestors.select { |a| a < RSpec::Core::ExampleGroup and a != RSpec::Core::ExampleGroup }
  end
end
