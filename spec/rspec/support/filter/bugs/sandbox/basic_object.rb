module SomeOtherModule
  def howdy
    puts 'stuff'
  end
end

example = Class.new do
  def basic_class
    Class.new(BasicObject) do
      def foo
        :bar
      end
    end
  end

  def inherited
    Class.new(basic_class) do
      # include ::Kernel
      include SomeOtherModule
    end
  end

  def run
    instance = inherited.new
    # This will fail in Opal <= 0.9 with undefined method `howdy'
    instance.howdy
  end
end

example.new.run
