[:be_an_instance_of, :be_instance_of].each do |method|
  describe "Opal expect(actual).to #{method}(expected)" do
    it "provides a description" do
      matcher = be_an_instance_of(Fixnum)
      matcher.matches?(Numeric)
      # opal fixnum == numeric
      # expect(matcher.description).to eq "be an instance of Fixnum"
      expect(matcher.description).to eq "be an instance of Numeric"
    end
  end
end
