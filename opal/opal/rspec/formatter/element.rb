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
  end
end