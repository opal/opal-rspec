module Opal
  module RSpec
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
        new(`#{dummy_div}.children[0]`)
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

      def get_child_by_tag_name(tag, index=0)
        elements = `#@native.getElementsByTagName(#{tag})`
        # is an HTMLCollection, not an array
        element_array = []
        %x{
          for (var i=0; i < #{elements}.length; i++) {
            #{element_array}.push(#{elements}[i]);
          }
        }
        Element.new(element_array[index])
      end

      def class_name=(name)
        `#@native.className = #{name}`
      end

      def native
        `#@native`
      end

      def outer_html
        `#@native.outerHTML`
      end

      def on_click=(lambda)
        `#@native.onclick = #{lambda}`
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
  end
end
