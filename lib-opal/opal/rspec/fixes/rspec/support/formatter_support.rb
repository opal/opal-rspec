module FormatterSupport
  def run_example_specs_with_formatter(formatter_option)
    options = RSpec::Core::ConfigurationOptions.new(%W[spec/rspec/core/resources/formatter_specs.rb --format #{formatter_option} --order defined])

    err, out = StringIO.new, StringIO.new
    err.set_encoding("utf-8") if err.respond_to?(:set_encoding)

    runner = RSpec::Core::Runner.new(options)
    configuration = runner.instance_variable_get("@configuration")
    configuration.backtrace_formatter.exclusion_patterns << /rspec_with_simplecov/
    configuration.backtrace_formatter.inclusion_patterns = []

    runner.run(err, out)

    # WAS:
    #   output = out.string
    #   output.gsub!(/\d+(?:\.\d+)?(s| seconds)/, "n.nnnn\\1")
    # NOW:
    output = out.string.gsub(/\d+(?:\.\d+)?(s| seconds)/, "n.nnnn\\1")

    caller_line = RSpec::Core::Metadata.relative_path(caller.first)
    output.lines.reject do |line|
      # remove the direct caller as that line is different for the summary output backtraces
      line.include?(caller_line) ||

      # ignore scirpt/rspec_with_simplecov because we don't usually have it locally but
      # do have it on travis
      line.include?("script/rspec_with_simplecov") ||

      # this line varies a bit depending on how you run the specs (via `rake` vs `rspec`)
      line.include?('/exe/rspec:')
    end.join
  end
end
