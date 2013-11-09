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
      person.name
    end
  end
end
