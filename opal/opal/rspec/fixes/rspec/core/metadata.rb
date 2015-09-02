class ::RSpec::Core::Metadata::ExampleGroupHash
  def described_class
    candidate = metadata[:description_args].first
    return candidate unless NilClass === candidate || String === candidate
    parent_group = metadata[:parent_example_group]
    puts "pg candidate #{parent_group} is a #{parent_group.class}" if parent_group.is_a? Hash
    # https://github.com/opal/opal/issues/1090
    # parent_group && parent_group[:described_class]
    # and didn't work either here (on MRI or on Opal)
    if parent_group
      parent_group[:described_class]
    else
      nil
    end
  end
end
