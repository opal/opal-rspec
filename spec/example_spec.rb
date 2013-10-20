module SomeHelpers
  def opal_rspec_helper
    let(:defined_opal_helper) { :it_works }
  end
end

module SomeMoreHelpers
  def opal_rspec_include_helper
    42
  end
end

RSpec.configure do |c|
  c.extend SomeHelpers
  c.include SomeMoreHelpers
end

describe "RSpec include and extend" do
  opal_rspec_helper

  it "works for extend" do
    defined_opal_helper.should == :it_works
  end

  it "works for include" do
    opal_rspec_include_helper.should == 42
  end
end

$count = 0

describe "let" do
  let(:count) { $count += 1 }

  it "memoizes the value" do
    count.should eq(1)
    count.should eq(1)
  end

  it "is not cached across examples" do
    count.should eq(2)
  end
end

describe "Simple expectations" do
  before do
    @bar = 200
  end

  it "should eat" do
    @bar.should == 200
  end

  after do
    @bar.class
  end
end

describe "should syntax" do
  it "should work for positive" do
    [1, 2, 3].should == [1, 2, 3]
  end

  it "should work for negative" do
    [1, 2, 3].should_not == [4, 5, 6]
  end
end

describe "Normal errors" do
  it "should still work" do
    lambda { raise "wtf son" }.should raise_error(Exception)
  end
end
