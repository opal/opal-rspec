module OpalFilters
  extend self

  # class FiltersFormatter < RSpec::Core::Formatters::BaseFormatter
    # RSpec::Core::Formatters.register self, :dump_summary
  ::RSpec::Core::Notifications::SummaryNotification.class_eval do
    def colorized_rerun_commands(colorizer=::RSpec::Core::Formatters::ConsoleCodes)
      "\nFilter failed examples:\n\n" +
      failed_examples.map do |example|
        output = colorizer.wrap("fails #{example.full_description.inspect}, ", RSpec.configuration.failure_color) + " "
        output += colorizer.wrap("#{example.execution_result.exception.message.strip.split("\n").first[0..100].inspect}", RSpec.configuration.detail_color)
      rescue
        # it's ok
      ensure
        output
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
    desc = example.full_description
    pending_message = OpalFilters.pending_message(desc)

    if OpalFilters.filtered?(desc)
      pending(pending_message)
    else
      example.call

      # Hacky hack: some examples don't have description (like it {})
      # and RSpec generates it *after* running the test
      # (basically it generates it from the expectation)
      desc = example.full_description
      pending_message = OpalFilters.pending_message(desc)
      if OpalFilters.filtered?(desc)
        # Flushing instance variable `@exception`
        # allows marking the test as pending after running
        # (Note: newer versions of RSpec don't require it)
        RSpec.current_example.instance_variable_set(:@exception, nil)
        pending("In runtime: #{pending_message}")
      end
    end
  end
end
