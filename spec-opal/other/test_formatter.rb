class TestFormatter < ::RSpec::Core::Formatters::JsonFormatter
  include FormatterDependency
  ::RSpec::Core::Formatters.register self, :message, :dump_summary, :dump_profile, :stop, :close

  def close(_notification)
    super
    output.write 'test formatter ran!'
  end
end
