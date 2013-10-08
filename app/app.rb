require 'opal'
require 'opal-rspec'

RSpec::Expectations::Syntax.enable_should
RSpec::Expectations::Syntax.enable_expect

# opal doesnt yet support module_exec for defining methods in modules properly
module RSpec::Matchers
  alias_method :expect, :expect
end

class TestEvalContext
  include RSpec::Matchers

  def self.fails
    @fails ||= []
  end

  def self.pass
    @pass ||= []
  end

  def self.should_fail(&block)
    fails << block
  end

  def self.should_pass(&block)
    pass << block
  end

  # expect syntax
  should_fail { expect(100).to eq(200) }

  # == (operator)
  should_fail { 1.should == 10 }
  should_fail { Object.new.should == self }
  should_fail { [1, 2, 3, 4].should == [1, 2, 3] }
  should_fail { "wow".should_not == "wow" }

  # be
  should_fail { 100.should be_nil }
  should_fail { false.should be_truthy }   # !!value - this breaks in opal parser (new Boolean(false) !== false)
  should_fail { true.should be_falsey }

  # be_kind_of
  should_fail { Object.new.should be_a_kind_of(Array) }

  # eq
  should_fail { Object.new.should eq(100) }
  should_fail { self.should_not eq(self) }

  # include
  should_fail { [1, 2, 3, 4].should include(5) }
  should_fail { { a: 200 }.should_not include(:a) }
end

# Run them:

puts "These #{TestEvalContext.fails.size} should all fail:\n"

TestEvalContext.fails.each_with_index do |test, idx|
  begin
    TestEvalContext.new.instance_eval(&test)
  rescue => err
    puts "#{idx + 1}. #{err.class.name}: #{err.message}"
  end
end
