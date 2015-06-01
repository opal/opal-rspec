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
  
  context 'promise returned by example' do
    async 'matcher fails properly' do
      promise = Promise.new
      delay 1 do
        1.should == 2
        promise.resolve
      end
      promise
    end

    async 'matcher succeeds properly' do
      promise = Promise.new
      delay 1 do
        1.should == 1
        promise.resolve
      end
      promise
    end

    describe 'promise fails properly' do
      async 'no args' do
        promise = Promise.new
        delay 1 do
          promise.reject
        end
        promise
      end

      async 'string arg' do
        promise = Promise.new
        delay 1 do
          promise.reject 'string failure reason here'
        end
        promise
      end

      async 'exception arg' do
        promise = Promise.new
        delay 1 do
          promise.reject TypeError.new('typeerror driven failure reason here')
        end
        promise
      end
    end
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

  context 'long delay' do
    async 'fail properly' do |done|
      @test_in_progress = 'can finish running after a long delay and fail properly'
      obj = [1, 2, 3, 4]

      delay(1) do
        obj.should == [2, 2, 3, 4]
        @test_in_progress = nil
        done.call
      end
    end

    async "succeed" do |done|
      obj = [1, 2, 3, 4]

      delay(1) do
        obj.should == [1, 2, 3, 4]
        done.call
      end
    end    
  end
  
  context 'skipped' do
    async 'via variable', skip: true do |done|
      obj = [1, 2, 3, 4]

      delay(1) do
        obj.should == [2, 2, 3, 4]
        done.call
      end
    end

    xasync 'via xasync' do |done|
      obj = [1, 2, 3, 4]

      delay(1) do
        obj.should == [2, 2, 3, 4]
        done.call
      end
    end

    async 'in example, no done call' do
      skip 'want to skip within'
    end
  
    async 'in example, with done call' do |done|
      skip 'want to skip within'
      done.call
    end    
  end
  
  context 'pending' do
    async 'in example without a done call' do
      obj = [1, 2, 3, 4]
      obj.should == [2, 2, 3, 4]
      pending 'want to pend within'
    end

    async 'in example with a done call' do |done|
      obj = [1, 2, 3, 4]

      delay(1) do
        obj.should == [2, 2, 3, 4]
        pending 'want to pend within'
        done.call
      end      
    end

    async 'via variable', pending: 'the reason' do |done|
      obj = [1, 2, 3, 4]

      delay(1) do
        obj.should == [2, 2, 3, 4]
        done.call
      end
    end    
  end
  
  # TODO, how to test this now? Right now, manually looking and ensuring failure message shows foo/baz and not 42/43
  async "should make example fail properly before async block reached" do |done|
    # Can't say "should raise exception" around an expectation anymore since expectations don't throw
    expect(:foo).to eq(:baz)

    delay(0) do
      expect(42).to eq(43)
      done.call
    end
  end
end

describe 'async/sync mix' do
  it 'fails properly if a sync test is among async tests' do
    1.should == 2
  end

  it 'passes correctly if a sync test is among async tests' do
    1.should == 1
  end

  async "can finish running after a long delay and fail properly" do |done|
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

describe 'async subject' do
  describe 'assertion' do
    subject do
      promise = Promise.new
      delay 1 do      
        promise.resolve 42
      end
      promise
    end
    
    context 'passes' do  
      async_it { is_expected.to eq 42 }
    end
    
    context 'assertion fails properly' do  
      async_it { is_expected.to eq 43 }
    end    
  end
    
  context 'fails properly during subject create' do
    subject do
      promise = Promise.new
      delay 1 do      
        promise.reject 'did not work'
      end
      promise
    end
    
    async_it { is_expected.to eq 42 }
  end
end

describe 'async before' do
  context 'by itself' do
    context 'succeeds' do
      pending 'write this'
    end
    
    context 'fails properly' do
      pending 'write this'
    end
  end
  
  context 'with async subject' do
    context 'both succeed' do
      pending 'write this'
    end
    
    context 'both fail properly' do
      pending 'write this'
    end
    
    context 'before succeeds, assertion fails properly' do
      pending 'write this'
    end
    
    context 'before fails properly' do
      pending 'write this'
    end
  end
end
