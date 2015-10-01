RSpec.configure do |c|
  # will make it easier to exclude certain specs
  c.default_formatter = ::RSpec::Core::Formatters::DocumentationFormatter if Opal::RSpec::Runner.phantom?
end
