describe "Asynchronous helpers" do

  let(:foo) { 100 }

  before do
    @model = Object.new
  end

  async "can run examples async" do
    run_async do
      1.should == 1
    end
  end

  async "can access let() helpers and before() helpers" do
    run_async do
      foo.should eq(100)
      @model.should be_kind_of(Object)
    end
  end

  async "can finish running after a long delay" do
    obj = [1, 2, 3, 4]

    set_timeout 100 do
      run_async { obj.should == [1, 2, 3, 4] }
    end
  end

  async "should make example fail before async block reached" do
    expect {
      expect(:foo).to eq(:baz)
    }.to raise_error(Exception)

    set_timeout(0) do
      run_async { expect(42).to eq(42) }
    end
  end
end
