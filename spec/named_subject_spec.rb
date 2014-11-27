describe "named subject" do
  subject(:named_subject) { [1, 2, 3] }

  it "should be the subject" do
    subject.should be_kind_of(Array)
  end

  it "should be the named subject" do
    subject.should eql(named_subject)
  end
end
