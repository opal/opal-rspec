describe "Asynchronous helpers" do
  let(:foo) { 100 }

  before do
    @model = Object.new
    @test_in_progress = nil
  end
  
  before :all do
    @@around_testing = []
    @@around_failures = []
  end
  
  around do |example|
    look_for = example.description
    @@around_testing << look_for
    # Result is the result of the test, aka the promised value from run (true if success, false if failed)
    # The complete_promise is needed so the runner knows when to continue
    example.run.then do |result, complete_promise|
      last = @@around_testing.pop
      @@around_failures << "Around hook kept executing even though test #{@test_in_progress} was running!" if @test_in_progress
      @@around_failures << "Around hooks are messed up because we expected #{look_for} but we popped off #{last}" unless last == look_for
      complete_promise.resolve
    end    
  end
  
  after :all do
    raise @@around_failures.join "\n" if @@around_failures.any?
    raise 'hooks not empty!' unless @@around_testing.empty?
  end
    
  it 'works with a sync test in a group of async tests with an around hook' do
    1.should == 1
  end
  
  async "can run examples async" do |done|
    1.should == 1
    done.call
  end

  async "can access let() helpers and before() helpers" do |done|
    foo.should eq(100)
    @model.should be_kind_of(Object)
    done.call
  end

  async "can finish running after a long delay and fail" do |done|
    @test_in_progress = 'can finish running after a long delay and fail'
    obj = [1, 2, 3, 4]

    delay(1) do
      obj.should == [2, 2, 3, 4]
      @test_in_progress = nil
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

  async 'skipped in example without a done call' do
    skip 'want to skip within'
  end
  
  async 'skipped in example with a done call' do |done|
    skip 'want to skip within'
    done.call
  end

  async 'pending in example without a done call' do
    obj = [1, 2, 3, 4]
    obj.should == [2, 2, 3, 4]
    pending 'want to pend within'
  end

  # TODO: This isn't working because the pending runs before the assertion failure, but we may be able to get rid of the 'done' thing entirely
  async 'pending in example with a done call' do |done|
    obj = [1, 2, 3, 4]

    delay(1) do
      obj.should == [2, 2, 3, 4]
      done.call
    end
    
    pending 'want to pend within'
  end

  async 'pending via variable', pending: 'the reason' do |done|
    obj = [1, 2, 3, 4]

    delay(1) do
      obj.should == [2, 2, 3, 4]
      done.call
    end
  end
  
  # TODO: test example group descendants
  
  # TODO, how to test this now? Right now, manually looking and ensuring failure message shows foo/baz and not 42/43
  async "should make example fail before async block reached" do |done|
    # Can't say "should raise exception" around an expectation anymore since expectations don't throw
    expect(:foo).to eq(:baz)

    delay(0) do
      expect(42).to eq(43)
      done.call
    end
  end
end

describe 'async/sync mix' do
  it 'fails correctly if a sync test is among async tests' do
    1.should == 2
  end
  
  it 'passes correctly if a sync test is among async tests' do
    1.should == 1
  end

  async "can finish running after a long delay and fail" do |done|
    @test_in_progress = 'can finish running after a long delay and fail'
    obj = [1, 2, 3, 4]

    delay(1) do
      obj.should == [2, 2, 3, 4]
      @test_in_progress = nil
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
end
