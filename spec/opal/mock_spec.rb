require 'spec_helper'

describe "RSpec mocks" do
  describe "stubs" do
    it "can stub basic methods" do
      obj = Object.new
      expect(obj).to receive(:foo) { 100 }
      obj.foo.should == 100
    end

    it "raises an exception when stub returns wrong value" do
      expect {
        obj = Object.new
        expect(obj).to receive(:bar) { 400 }
        obj.bar.should == 42
      }.to raise_error(Exception)
    end

    it "allow" do
      obj = Object.new
      allow(obj).to receive(:name) { "Adam B" }
      allow(obj).to receive(:job).and_return("Eating Fruit Gums")

      expect(obj.name).to eq("Adam B")
      expect(obj.job).to eq("Eating Fruit Gums")
    end

    it "expecting arguments" do
      person = double("person")
      expect(person).to receive(:foo).with(4, 5, 6)
      person.foo(4, 5, 6)
    end
  end

  describe "doubles" do
    it "define methods on double" do
      person = double("person", :name => "Adam")
      expect(person.name).to eq("Adam")
    end

    it "once" do
      person = double("person")
      expect(person).to receive(:name).once
      person.name.should eq(nil)
    end

    it "twice" do
      person = double("person")
      expect(person).to receive(:name).twice
      person.name
      person.name.should
    end
  end

  it "can mock existing methods on objects" do
    expect(Time).to receive(:now).once.and_call_original
    Time.now.should be_kind_of(Time)
  end

  describe 'stubs' do
    it 'works and displays deprecation' do
      Object.new.stub :foo
    end
  end
end
