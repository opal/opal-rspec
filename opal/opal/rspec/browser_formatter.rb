module Opal
  module RSpec
    class DocumentIO < IO
      include IO::Writable

      def initialize
        `document.open();`
      end

      def close
        @closed = true
        `document.close()`
      end

      def write(html)
        if @closed
          `console.error(#{"DOC closed, can't write #{html}" })`
        else
          `document.write(#{html})`
        end
      end

      def flush
      end
    end

    class Element
      attr_reader :native

      def self.id(id)
        new(`document.getElementById(id)`)
      end

      def self.klass(klass)
        new(`document.getElementsByClassName(#{klass})[0]`)
      end

      def self.from_string(str)
        dummy_div = `document.createElement('div')`
        `#{dummy_div}.innerHTML = #{str}`
        new(`#{dummy_div}.firstChild`)
      end

      def initialize(el, attrs={})
        if String === el
          @native = `document.createElement(el)`
        else
          @native = el
        end

        attrs.each { |name, val| __send__ "#{name}=", val }
      end

      def class_name
        `#@native.className`
      end

      def class_name=(name)
        `#@native.className = #{name}`
      end

      def html=(html)
        `#@native.innerHTML = #{html}`
      end

      def text=(text)
        self.html = text.gsub(/</, '&lt').gsub(/>/, '&gt')
      end

      def type=(type)
        `#@native.type = #{type}`
      end

      def append(child)
        `#@native.appendChild(#{child.native})`
      end

      alias << append

      def css_text=(text)
        %x{
                if (#@native.styleSheet) {
                  #@native.styleSheet.cssText = #{text};
                }
                else {
                  #@native.appendChild(document.createTextNode(#{text}));
                }
              }
      end

      def style(name, value)
        `#@native.style[#{name}] = value`
      end

      def append_to_head
        `document.getElementsByTagName('head')[0].appendChild(#@native)`
      end
    end

    class OurStringIO < StringIO
      # make printer happy
      def flush
      end
    end

    class HtmlPrinter < ::RSpec::Core::Formatters::HtmlPrinter
      def initialize(output)
        super
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
        @results = Element.klass 'results'
      end

      def flush_output
        @results.append Element.from_string(@output.string)
        reset_output
      end

      def reset_output
        @output = OurStringIO.new
      end

      def print_example_group_start(group_id, description, number_of_parents)
        super
        # We won't have this in the DOM until group ends, so need to queue up yellow/red updates
        @pending_group_updates = []
      end

      def print_example_group_end
        super
        flush_output
        @pending_group_updates.each(&:call)
      end

      def print_example_passed(description, run_time)
        super
        flush_output
      end

      def print_example_failed(pending_fixed, description, run_time, failure_id, exception, extra_content, escape_backtrace=false)
        super
        flush_output
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
        @pending_group_updates << lambda do
          `makeRed(#{"div_group_#{group_id}"})`
          `makeRed(#{"example_group_#{group_id}"})`
        end
      end

      def make_example_group_header_yellow(group_id)
        @pending_group_updates << lambda do
          `makeYellow(#{"div_group_#{group_id}"})`
          `makeYellow(#{"example_group_#{group_id}"})`
        end
      end
    end

    class BrowserFormatter < ::RSpec::Core::Formatters::HtmlFormatter
      include ERB::Util

      ::RSpec::Core::Formatters.register self, :start, :example_group_started, :start_dump,
                                         :example_started, :example_passed, :example_failed,
                                         :example_pending, :dump_summary

      def initialize(output)
        super DocumentIO.new
        @printer = Opal::RSpec::HtmlPrinter.new(@output)
      end

      def extra_failure_content(failure)
        backtrace = failure.exception.backtrace.map { |line| ::RSpec.configuration.backtrace_formatter.backtrace_line(line) }
        # No snippet extractor due to code ray dependency
        "    <pre class=\"ruby\"><code>#{backtrace.compact}</code></pre>"
      end
    end
  end
end
