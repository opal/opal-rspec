require 'opal'
require 'opal-rspec'

describe "Adam" do
  before do
    puts "a"
    @bar = 200
  end

  it "should eat" do
    1.should == 1
    @bar.should == 201
  end
end

describe "Benjamin" do
  it "likes cream in his tea" do
    1.should == 3
  end

  it "should eat bacon" do
    "bacon".should be_a_kind_of(String)
  end
end

describe "Some let tests" do
  let(:adam) { 100 }

  it "should eat pieee" do
    adam.should == 200
  end
end

describe "Normal errors" do
  it "should still work" do
    raise "wtf son"
  end
end

RSpec.configure do |config|
  config.formatter = OpalRSpec::TextFormatter
end

OpalRSpec::Runner.new.run
