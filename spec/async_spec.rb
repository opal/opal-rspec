describe "Asynchronous helpers" do
  let(:foo) { 100 }

  before do
    @model = Object.new
  end
  
  async 'allows overriding the timeout', timeout: 15 do
    delay(11) do
      async do
        expect(42).to eq(42)
        expect(@@moved_on).to eq(false), 'The following example that sets this should not start until we are done but it did'
      end
    end
  end

  async "can run examples async" do
    @@moved_on = true
    async do
      1.should == 1
    end
  end

  async "can access let() helpers and before() helpers" do
    async do
      foo.should eq(100)
      @model.should be_kind_of(Object)
    end
  end

  async "can finish running after a long delay" do
    obj = [1, 2, 3, 4]

    delay(1) do
      async { obj.should == [1, 2, 3, 4] }
    end
  end

  async "should make example fail before async block reached" do
    expect {
      expect(:foo).to eq(:baz)
    }.to raise_error(Exception)

    delay(0) do
      async { expect(42).to eq(42) }
    end
  end
end
