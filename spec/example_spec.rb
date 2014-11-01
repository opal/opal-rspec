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

describe "helper methods" do
  def some_helper
    :present
  end

  it "should be available" do
    some_helper.should eq(:present)
  end

  describe "nested group" do
    it "should work in nested groups" do
      some_helper.should eq(:present)
    end
  end
end

describe "nested describes" do
  it "works in multiple places" do
    1.should eq(1)
  end

  describe "nested" do
    it "and here" do
      1.should_not eq(2)
    end
  end
end

describe "subject" do
  subject { [1, 2, 3] }

  it "a new instance should be the subject" do
    subject.should be_kind_of(Array)
  end

  describe "nested subjects" do
    before { subject << 4 }

    it "should work with before and example" do
      subject.should == [1, 2, 3, 4]
    end
  end
end

describe Hash do
  it "should create a new instance of subject for classes" do
    subject.should == {}
  end

  it "provides the subject as the described_class" do
    expect(described_class).to eq(Hash)
  end
end

describe [1, 2, 3] do
  it "can use an object instance as a subject" do
    expect(subject).to eq([1, 2, 3])
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

describe "expect syntax" do
  it "positive expectation" do
    expect(100).to eq(100)
  end

  it "negative expectation" do
    expect(100).to_not eq(300)
  end
end

describe "one-liner syntax" do
  subject { 42 }

  describe "is_expected" do
    it { is_expected.to eq(42) }
    it { is_expected.to_not eq(43) }
  end

  describe "should" do
    it { should == 42 }
    it { should_not == 43 }
  end
end

describe "Normal errors" do
  it "should still work" do
    lambda { raise "wtf son" }.should raise_error(Exception)
  end
end

describe "let on an inner scope" do
  describe "inner context" do
    let(:foo) { :bar }

    it "should still work" do
      foo.should eq(:bar)
    end
  end
end
