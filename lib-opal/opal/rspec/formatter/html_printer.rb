# backtick_javascript: true

require_relative 'noop_flush_string_io'
require_relative 'element'

module Opal
  module RSpec
    class HtmlPrinter < ::RSpec::Core::Formatters::HtmlPrinter
      def initialize(output)
        super
        @group_stack = []
        @update_stack = []
      end

      def print_html_start
        # Will output the header
        super
        # Now close out the doc so we can use DOM manipulation for the rest
        @output.puts "</div>"
        @output.puts "</div>"
        @output.puts "</body>"
        @output.puts "</html>"
        @output.close
        # From here, we'll do more direct DOM manipulation
        reset_output
        @root_node = Element.klass 'results'
      end

      def current_node
        @group_stack.last ? @group_stack.last : @root_node
      end

      def flush_output
        node = current_node
        new_node = Element.from_string(@output.string)
        node.append new_node
        reset_output
      end

      def reset_output
        @output = NoopFlushStringIO.new
      end

      def print_example_group_start(group_id, description, number_of_parents)
        super
        @output.puts '</dl></div>'
        parent_node = current_node
        new_node = Element.from_string(@output.string)
        reset_output
        parent_node << new_node
        @group_stack << new_node.get_child_by_tag_name('dl')
        # We won't have this in the DOM until group ends, so need to queue up yellow/red updates
        @update_stack << []
      end

      def print_example_group_end
        @group_stack.pop
        @update_stack.pop.each(&:call)
      end

      def print_example_passed(description, run_time)
        super
        flush_output
      end

      def print_example_failed(pending_fixed, description, run_time, failure_id, exception, extra_content)
        super
        flush_output
        example_we_just_wrote = current_node.get_child_by_tag_name('dd', index=-1)
        dump_message = lambda do |*|
          puts "Exception for example '#{description}'\n#{exception[:backtrace]}"
          false
        end
        button = Element.from_string('<form><button type="button">Console</button></form>')
        button.on_click = dump_message
        example_we_just_wrote << button
      end

      def print_example_pending(description, pending_message)
        super
        flush_output
      end

      def print_summary(duration, example_count, failure_count, pending_count)
        # string mutation
        totals = "#{example_count} example#{'s' unless example_count == 1}, "
        totals += "#{failure_count} failure#{'s' unless failure_count == 1}"
        totals += ", #{pending_count} pending" if pending_count > 0

        formatted_duration = "%.5f" % duration
        Element.id('duration').html = "Finished in <strong>#{formatted_duration} seconds</strong>"
        Element.id('totals').html = totals
      end

      # Directly manipulate scripts here
      def move_progress(percent_done)
        `moveProgressBar(#{percent_done})`
      end

      def make_header_red
        `makeRed('rspec-header')`
      end

      def make_header_yellow
        `makeYellow('rspec-header')`
      end

      def make_example_group_header_red(group_id)
        @update_stack.last << lambda do
          `makeRed(#{"div_group_#{group_id}"})`
          `makeRed(#{"example_group_#{group_id}"})`
        end
      end

      def make_example_group_header_yellow(group_id)
        @update_stack.last << lambda do
          `makeYellow(#{"div_group_#{group_id}"})`
          `makeYellow(#{"example_group_#{group_id}"})`
        end
      end
    end
  end
end
