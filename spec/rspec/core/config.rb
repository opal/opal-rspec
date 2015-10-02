RSpec.configure do |c|
  # will make it easier to exclude certain specs
  c.default_formatter = ::RSpec::Core::Formatters::DocumentationFormatter if ::RSpec::Core::Runner.non_browser?
  #c.full_description = 'uses the default color for the shared example backtrace line'
end
