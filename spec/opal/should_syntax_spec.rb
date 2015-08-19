describe "One-liner should syntax" do
  subject { 42 }

  describe "should" do
    it { should == 42 }
    it { should_not == 43 }
  end

  describe "is_expected" do
    it { is_expected.to eq(42) }
    it { is_expected.to_not eq(43) }
  end

  describe "expect" do
    it { expect(42).to eq(42) }
  end
end
