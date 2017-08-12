require 'spec_helper'

describe "be_truthy" do
  it "passes with truthy values" do
    expect(true).to be_truthy
    expect(1.0).to be_truthy
    expect([]).to be_truthy
  end

  it 'fails properly with truthy values' do
    expect(false).to be_truthy
  end

  it "fails with falsey values" do
    expect {
      expect(false).to be_truthy
    }.to raise_error(Exception)

    expect {
      expect(nil).to be_truthy
    }.to raise_error(Exception)
  end
end

describe "be_falsey" do
  it "passes with falsey values" do
    expect(false).to be_falsey
    expect(nil).to be_falsey
  end

  it "fails with truthy values" do
    expect {
      expect(true).to be_falsey
    }.to raise_error(Exception)

    expect {
      expect({}).to be_falsey
    }.to raise_error(Exception)
  end
end

describe "be_nil" do
  it "passes when object is nil" do
    expect(nil).to be_nil
  end

  it "fails with any other object" do
    expect {
      expect(false).to be_nil
    }.to raise_error(Exception)

    expect {
      expect(:foo).to be_nil
    }.to raise_error(Exception)
  end
end

describe "be_kind_of" do
  it "passes if actual is kind of expected class" do
    expect("foo").to be_kind_of(String)
    expect("foo").to_not be_kind_of(Numeric)
  end

  it "passes if actual is kind of superclass of expected class" do
    expect([]).to be_kind_of(Object)
  end

  it "fails if expected is not a kind of expected" do
    expect {
      expect("foo").to be_kind_of(Integer)
    }.to raise_error(Exception)

    expect {
      expect("foo").to_not be_kind_of(String)
    }.to raise_error(Exception)
  end
end

describe "eq" do
  it "matches when actual == expected" do
    expect(:foo).to eq(:foo)
  end

  it "does not match when actual != expected" do
    expect(:foo).not_to eq(42)
  end

  it "fails if matcher does not match" do
    expect {
      expect(:foo).to eq(42)
    }.to raise_error(Exception)

    expect {
      expect(:foo).not_to eq(:foo)
    }.to raise_error(Exception)
  end
end

describe "eql" do
  it "matches when expected.eql?(actual)" do
    expect(1).to eql(1)
  end

  it "does not match when !expected.eql?(actual)" do
    expect(1).to_not eql(:foo)
  end

  it "fails if matcher does not match" do
    expect {
      expect(1).to eql(:bar)
    }.to raise_error(Exception)

    expect {
      expect(2).to_not eql(2)
    }.to raise_error(Exception)
  end
end

describe "include" do
  it "matches if actual includes expected" do
    expect("foo").to include("f")
    expect([:foo, :bar, :baz]).to include(:baz)
    expect({ :yellow => 'lorry' }).to include(:yellow)
  end

  it "does not match if actual does not inlcude expected" do
    expect("foo").to_not include("b")
    expect([:foo, :bar, :baz]).to_not include(:kapow)
    expect({ :yellow => 'lorry' }).to_not include(:red)
  end

  it "fails if matcher does not match" do
    expect {
      expect("bar").to include("z")
    }.to raise_error(Exception)
  end
end

describe "respond_to" do
  it "matches if actual responds to sym" do
    expect("foo").to respond_to(:upcase)
  end

  it "does not match if actual does not respond to sym" do
    expect(Object.new).to_not respond_to(:upcase)
  end

  it "fails if actual does not respond to sym" do
    expect {
      expect(Object.new).to respond_to(:upcase)
    }.to raise_error(Exception)
  end
end

describe "match" do
  it "matches if actual matches expected" do
    expect("foobar").to match(/ar/)
    expect("foobar").to match("oob")
  end

  it "does not match if actual does not match expected" do
    expect("foobar").to_not match(/baz/)
    expect("foobar").to_not match("woosh")
  end

  it "fails unless matcher matches" do
    expect {
      exprct("hello").to match(/world/)
    }.to raise_error(Exception)
  end
end

describe "operator ==" do
  it "matches if actual == expected" do
    "hello".should == "hello"
  end

  it "does not match when actual does not == expected" do
    "hello".should_not == "world"
  end

  it "fails unless matcher matches" do
    expect {
      "hello".should == "world"
    }.to raise_error(Exception)
  end
end

class PredicateTest
  def foo?
    true
  end

  def bar?
    false
  end
end

describe "predicate matchers" do
  it "works with positive expectations" do
    expect(PredicateTest.new).to be_foo
  end

  it "work with negative expectations" do
    expect(PredicateTest.new).to_not be_bar
  end
end
