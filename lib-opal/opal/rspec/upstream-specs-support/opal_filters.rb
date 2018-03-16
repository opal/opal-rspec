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

  FIXME = 'FIXME'

  def fails(full_description, note = nil)
    note = "#{name}: #{note || FIXME}"
    @filters[full_description] = note || full_description
  end

  alias fails_context fails

  def filtered?(full_description)
    @filters[full_description]
  end

  def pending_message(full_description)
    note = @filters[full_description]
    "#{@name}: #{note}"
  end
end

module SkipContextSupport
  def context(description, *args, &block)
    full_description = metadata[:full_description] + ' ' + description
    if OpalFilters.filtered?(full_description)
      puts "SKIPPING #{full_description}"
    else
      super
    end
  end
end

RSpec.configure do |config|
  config.extend(SkipContextSupport)

  config.around(:each) do |example|
    if OpalFilters.filtered?(example.full_description)
      pending OpalFilters.pending_message(example.full_description)
    else
      example.call
    end
  end
end
