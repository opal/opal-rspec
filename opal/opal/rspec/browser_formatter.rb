require 'erb'

module Opal
  module RSpec
    class BrowserFormatter < ::RSpec::Core::Formatters::BaseFormatter
      include ERB::Util
      
      ::RSpec::Core::Formatters.register self, :dump_summary, :example_group_finished, :example_failed, :example_passed, :example_pending

      CSS_STYLES = ::RSpec::Core::Formatters::HtmlPrinter::GLOBAL_STYLES

      def start(example_count)
        super
        target = Element.new(`document.body`)
        target << Element.new(:div, html: REPORT_TEMPLATE)
        @rspec_results = Element.id('rspec-results')

        css_text = CSS_STYLES + "\n body { padding: 0; margin: 0 }"
        styles = Element.new(:style, type: 'text/css', css_text: css_text)
        styles.append_to_head
      end

      def example_group_started(notification)
        super

        @example_group_failed = false
        parents = @example_group.parent_groups.size

        @rspec_group  = Element.new(:div, class_name: "example_group passed")
        @rspec_dl     = Element.new(:dl)
        @rspec_dt     = Element.new(:dt, class_name: "passed", text: example_group.description)
        @rspec_group << @rspec_dl
        @rspec_dl << @rspec_dt

        @rspec_dl.style 'margin-left', "#{(parents - 2) * 15}px"

        @rspec_results << @rspec_group
      end

      def example_group_finished(_notification)
        puts "REPORTER - got example_group_finished #{_notification}"
        if @example_group_failed
          @rspec_group.class_name = "example_group failed"
          @rspec_dt.class_name = "failed"
          Element.id('rspec-header').class_name = 'failed'
        end
        
        if @example_group_pending
          @rspec_group.class_name = "example_group not_implemented"
          @rspec_dt.class_name = "pending"          
          header = Element.id('rspec-header')
          # Don't want to override failed with pending, which is less important
          header.class_name = 'not_implemented' unless header.class_name == 'failed'
        end
      end
      
      def example_pending(notification)
        example = notification.example
        duration = sprintf("%0.5f", example.execution_result.run_time)
        
        pending_message = example.execution_result.pending_message

        @example_group_pending = true

        @rspec_dl << Element.new(:dd, class_name: "example not_implemented", html: <<-HTML)
          <span class="not_implemented_spec_name">#{h example.description} (PENDING: #{h(pending_message)})</span>          
        HTML
      end

      def example_failed(notification)
        puts "REPORTER - got ex failed #{notification}"
        example = notification.example
        duration = sprintf("%0.5f", example.execution_result.run_time)

        error = example.execution_result.exception
        error_name = error.class.name.to_s
        output = "#{short_padding}#{error_name}:\n"
        error.message.to_s.split("\n").each { |line| output += "#{long_padding}  #{line}\n" }
        error.backtrace.each {|trace| output += "#{long_padding}  #{trace}\n"}

        @example_group_failed = true

        @rspec_dl << Element.new(:dd, class_name: "example failed", html: <<-HTML)
          <span class="failed_spec_name">#{h example.description}</span>
          <span class="duration">#{duration}s</span>
          <div class="failure">
            <div class="message"><pre>#{h output}</pre></div>
          </div>
        HTML
      end

      def example_passed(notification)
        example = notification.example      
        duration = sprintf("%0.5f", example.execution_result.run_time)

        @rspec_dl << Element.new(:dd, class_name: "example passed", html: <<-HTML)
          <span class="passed_spec_name">#{h example.description}</span>
          <span class="duration">#{duration}s</span>
        HTML
      end     

      def dump_summary(notification)
        totals = "#{notification.example_count} examples, #{notification.failure_count} failures, #{notification.pending_count} pending"
        Element.id('totals').html = totals

        duration = "Finished in <strong>#{sprintf("%.5f", notification.duration)} seconds</strong>"
        Element.id('duration').html = duration

        add_scripts
      end

      def add_scripts
        content = ::RSpec::Core::Formatters::HtmlPrinter::GLOBAL_SCRIPTS
        `window.eval(#{content})`
      end

      def short_padding
        '  '
      end

      def long_padding
        '     '
      end

      class Element
        attr_reader :native

        def self.id(id)
          new(`document.getElementById(id)`)
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

      REPORT_TEMPLATE = <<-EOF
<div class="rspec-report">

  <div id="rspec-header">
    <div id="label">
      <h1>RSpec Code Examples</h1>
    </div>

    <div id="display-filters">
      <input id="passed_checkbox"  name="passed_checkbox"  type="checkbox" checked="checked" onchange="apply_filters()" value="1" /> <label for="passed_checkbox">Passed</label>
      <input id="failed_checkbox"  name="failed_checkbox"  type="checkbox" checked="checked" onchange="apply_filters()" value="2" /> <label for="failed_checkbox">Failed</label>
      <input id="pending_checkbox" name="pending_checkbox" type="checkbox" checked="checked" onchange="apply_filters()" value="3" /> <label for="pending_checkbox">Pending</label>
    </div>

    <div id="summary">
      <p id="totals">&#160;</p>
      <p id="duration">&#160;</p>
    </div>
  </div>

  <div id="rspec-results" class="results">
  </div>
</div>
EOF
    end
  end
end
