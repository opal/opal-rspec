describe "Asynchronous helpers" do
  let(:foo) { 100 }

  before do
    @model = Object.new
  end
  
  # async "can run examples async" do |done|
  #   1.should == 1
  #   done.call
  # end
  #
  # async "can access let() helpers and before() helpers" do |done|
  #   foo.should eq(100)
  #   @model.should be_kind_of(Object)
  #   done.call
  # end

  async "can finish running after a long delay and fail" do |done|
    obj = [1, 2, 3, 4]

    delay(1) do
      obj.should == [2, 2, 3, 4]
      done.call
    end
  end
  
  async "can finish running after a long delay and succeed" do |done|
    obj = [1, 2, 3, 4]

    delay(1) do
      obj.should == [1, 2, 3, 4]
      done.call
    end
  end  
  
  async 'skipped via variable', skip: true do |done|
    obj = [1, 2, 3, 4]

    delay(1) do
      obj.should == [2, 2, 3, 4]
      done.call
    end
  end
  
  xasync 'skipped via xasync' do |done|
    obj = [1, 2, 3, 4]

    delay(1) do
      obj.should == [2, 2, 3, 4]
      done.call
    end
  end
  
  # async 'skipped in example' do |done|
  #   skip
  # end
  
  # async 'pending in example' do |done|
  #   pending 'not ready yet'
  # end
  
  async 'pending via variable', pending: 'the reason' do |done|
    obj = [1, 2, 3, 4]

    delay(1) do
      obj.should == [2, 2, 3, 4]
      done.call
    end
  end
  
  # TODO: test descendants
  #
  #
  # async "should make example fail before async block reached" do
  #   expect {
  #     expect(:foo).to eq(:baz)
  #   }.to raise_error(Exception)
  #
  #   delay(0) do
  #     async { expect(42).to eq(42) }
  #   end
  # end
end
