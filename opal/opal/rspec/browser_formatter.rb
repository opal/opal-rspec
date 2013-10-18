require 'opal/rspec/text_formatter'

module Opal; module RSpec
  class BrowserFormatter < TextFormatter

    def start(example_count)
      super

      @summary_element = Element.new(:p, class_name: 'summary', text: 'Runner...')
      @groups_element = Element.new(:ul, class_name: 'example_groups')

      target = Element.new(`document.body`)
      target << @summary_element
      target << @groups_element

      styles = Element.new(:style, type: 'text/css', css_text: CSS)
      styles.append_to_head
    end

    def example_group_started(example_group)
      super

      @example_group_failed = false
      @group_element = Element.new(:li)

      description = Element.new(:span, class_name: 'group_description', text: example_group.description)
      @group_element << description

      @example_list = Element.new(:ul, class_name: 'examples')
      @group_element << @example_list

      @groups_element << @group_element
    end

    def example_group_finished(example_group)
      super

      if @example_group_failed
        @group_element.class_name = 'group failed'
      else
        @group_element.class_name = 'group passed'
      end
    end

    def example_failed(example)
      super

      @example_group_failed = true

      error = example.execution_result[:exception]
      error_name = error.class.name.to_s
      output = "#{short_padding}#{error_name}:\n"
      error.message.to_s.split("\n").each { |line| output += "#{long_padding}  #{line}\n" }

      wrapper = Element.new(:li, class_name: 'example failed')

      description = Element.new(:span, class_name: 'example_description', text: example.description)
      wrapper << description

      exception = Element.new(:pre, class_name: 'exception', text: output)
      wrapper << exception

      @example_list << wrapper
      @example_list.style :display, 'list-item'
    end

    def example_passed(example)
      super

      wrapper = Element.new(:li, class_name: 'example passed')
      description = Element.new(:span, class_name: 'example_description', text: example.description)

      wrapper << description
      @example_list << wrapper
    end

    def dump_summary(duration, example_count, failure_count, pending_count)
      super

      summary = "\n#{example_count} examples, #{failure_count} failures (time taken: #{duration})"
      @summary_element.text = summary
    end

    class Element
      attr_reader :native

      def initialize(el, attrs={})
        if String === el
          @native = `document.createElement(el)`
        else
          @native = el
        end

        attrs.each { |name, val| __send__ "#{name}=", val }
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

    CSS = <<-CSS

      body {
        font-size: 14px;
        font-family: Helvetica Neue, Helvetica, Arial, sans-serif;
      }

      pre {
        font-family: "Bitstream Vera Sans Mono", Monaco, "Lucida Console", monospace;
        font-size: 12px;
        color: #444444;
        white-space: pre;
        padding: 3px 0px 3px 12px;
        margin: 0px 0px 8px;

        background: #FAFAFA;
        -webkit-box-shadow: rgba(0,0,0,0.07) 0 1px 2px inset;
        -webkit-border-radius: 3px;
        -moz-border-radius: 3px;
        border-radius: 3px;
        border: 1px solid #DDDDDD;
      }

      ul.example_groups {
        list-style-type: none;
      }

      li.group.passed .group_description {
        color: #597800;
        font-weight: bold;
      }

      li.group.failed .group_description {
        color: #FF000E;
        font-weight: bold;
      }

      li.example.passed {
        color: #597800;
      }

      li.example.failed {
        color: #FF000E;
      }

      .examples {
        list-style-type: none;
      }
    CSS
  end
end; end
