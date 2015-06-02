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
    it 'matcher fails properly' do
      promise = Promise.new
      delay 1 do
        1.should == 2
        promise.resolve
      end
      promise
    end

    it 'matcher succeeds properly' do
      promise = Promise.new
      delay 1 do
        1.should == 1
        promise.resolve
      end
      promise
    end

    describe 'promise fails properly' do
      it 'no args' do
        promise = Promise.new
        delay 1 do
          promise.reject
        end
        promise
      end

      it 'string arg' do
        promise = Promise.new
        delay 1 do
          promise.reject 'string failure reason here'
        end
        promise
      end

      it 'exception arg' do
        promise = Promise.new
        delay 1 do
          promise.reject TypeError.new('typeerror driven failure reason here')
        end
        promise
      end
    end
  end
  
  context 'skipped' do
    it 'via variable', skip: true do
      obj = [1, 2, 3, 4]

      delay_with_promise 1 do
        obj.should == [2, 2, 3, 4]
      end
    end

    xit 'via xasync' do
      obj = [1, 2, 3, 4]

      delay_with_promise 1 do
        obj.should == [2, 2, 3, 4]
      end
    end

    it 'in example, no promise' do
      skip 'want to skip within'
    end
  
    it 'in example, inside promise' do
      delay_with_promise 1 do
        skip 'want to skip within'
      end
    end
  
    it 'in example, outside promise' do
      skip 'want to skip within'
      delay_with_promise 1 do
        1.should == 1
      end      
    end    
  end
  
  context 'pending' do
    it 'in example without a promise' do
      obj = [1, 2, 3, 4]
      obj.should == [2, 2, 3, 4]
      pending 'want to pend within'
    end

    it 'in example with a promise' do
      obj = [1, 2, 3, 4]

      delay_with_promise(1) do
        obj.should == [2, 2, 3, 4]
        pending 'want to pend within'
      end      
    end

    it 'via variable', pending: 'the reason' do
      obj = [1, 2, 3, 4]

      delay_with_promise(1) do
        obj.should == [2, 2, 3, 4]
      end
    end    
  end
  
  # TODO, how to test this now? Right now, manually looking and ensuring failure message shows foo/baz and not 42/43
  it "should make example fail properly before async block reached" do
    # Can't say "should raise exception" around an expectation anymore since expectations don't throw
    expect(:foo).to eq(:baz)

    delay_with_promise(0) do
      expect(42).to eq(43)
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

  it "can finish running after a long delay and fail properly" do
    @test_in_progress = 'can finish running after a long delay and fail'
    obj = [1, 2, 3, 4]

    delay_with_promise(1) do
      obj.should == [2, 2, 3, 4]
      @test_in_progress = nil
    end
  end

  it "can finish running after a long delay and succeed" do
    obj = [1, 2, 3, 4]

    delay_with_promise(1) do
      obj.should == [1, 2, 3, 4]
    end
  end
end
