module OpalFilters
  extend self

  # class FiltersFormatter < RSpec::Core::Formatters::BaseFormatter
    # RSpec::Core::Formatters.register self, :dump_summary
  ::RSpec::Core::Notifications::SummaryNotification.class_eval do
    def colorized_rerun_commands(colorizer=::RSpec::Core::Formatters::ConsoleCodes)
      "\nFilter failed examples:\n\n" +
      failed_examples.map do |example|
        colorizer.wrap("fails #{example.full_description.inspect}, ", RSpec.configuration.failure_color) + " " +
        colorizer.wrap("#{example.execution_result.exception.message.strip.split("\n").first[0..100].inspect}", RSpec.configuration.detail_color)
      end.join("\n")
    end
  end

  def group(name, &block)
    old_name = @name
    @name = name
    @filters ||= {}
    instance_eval(&block)
    @name = old_name
  end

  def fails full_description, note = nil
    note = "#{name}: #{note || FIXME}"
    @filters[full_description] = note || full_description
  end

  def filtered?(example)
    @filters[example.full_description]
  end

  def pending_message(example)
    note = @filters[example.full_description]
    "#{@name}: #{note}"
  end
end

RSpec.configure do |config|
  config.around(:each) do |example|
    # puts '|||'+example.full_description+'|||' if example.full_description.include? 'when a custom order'
    pending OpalFilters.pending_message(example) if OpalFilters.filtered?(example)
    example.call
  end
end
