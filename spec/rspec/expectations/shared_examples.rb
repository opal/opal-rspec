RSpec.shared_context "with #should enabled", :uses_should do
  orig_syntax = nil

  before(:all) do
    orig_syntax = RSpec::Matchers.configuration.syntax
    RSpec::Matchers.configuration.syntax = [:expect, :should]
  end

  after(:context) do
    RSpec::Matchers.configuration.syntax = orig_syntax
  end
end

RSpec.shared_context "with the default expectation syntax" do
  orig_syntax = nil

  before(:context) do
    orig_syntax = RSpec::Matchers.configuration.syntax
    RSpec::Matchers.configuration.reset_syntaxes_to_default
  end

  after(:context) do
    RSpec::Matchers.configuration.syntax = orig_syntax
  end

end

RSpec.shared_context "with #should exclusively enabled", :uses_only_should do
  orig_syntax = nil

  before(:context) do
    orig_syntax = RSpec::Matchers.configuration.syntax
    RSpec::Matchers.configuration.syntax = :should
  end

  after(:context) do
    RSpec::Matchers.configuration.syntax = orig_syntax
  end
end

RSpec.shared_context "isolate include_chain_clauses_in_custom_matcher_descriptions" do
  around do |ex|
    orig = RSpec::Expectations.configuration.include_chain_clauses_in_custom_matcher_descriptions?
    ex.run
    RSpec::Expectations.configuration.include_chain_clauses_in_custom_matcher_descriptions = orig
  end
end
