require 'opal'
require 'opal-rspec'

class TestEvalContext
  include RSpec::Matchers
end

failing = [
  # == (operator)
  -> { 1.should == 10 },
  -> { Object.new.should == self },
  -> { [1, 2, 3, 4].should == [1, 2, 3] },
  -> { "wow".should_not == "wow" },

  # be
  -> { 100.should be_nil },
  -> { false.should be_truthy },   # !!value - this breaks in opal parser (new Boolean(false) !== false)
  -> { true.should be_falsey },

  # be_kind_of
  -> { Object.new.should be_a_kind_of(Array) },

  # eq
  -> { Object.new.should eq(100) },
  -> { self.should_not eq(self) },

  # include
  -> { [1, 2, 3, 4].should include(5) },
  -> { { a: 200 }.should_not include(:a) }
]

puts "These #{failing.size} should all fail:\n"

failing.each_with_index do |test, idx|
  begin
    TestEvalContext.new.instance_eval(&test)
  rescue => err
    puts "#{idx + 1}. #{err.class.name}: #{err.message}"
  end
end
