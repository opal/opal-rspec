class ::RSpec::Core::Metadata::ExampleGroupHash
  def described_class
    candidate = metadata[:description_args].first
    return candidate unless NilClass === candidate || String === candidate
    parent_group = metadata[:parent_example_group]
    # https://github.com/opal/opal/issues/1090
    # parent_group && parent_group[:described_class]
    result = parent_group and parent_group[:described_class]
    # also need an explicit return here, leaving until the last line causes problems
    result
  end
end
