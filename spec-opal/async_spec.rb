require 'opal/rspec/async'
require 'spec_helper'

describe 'promise' do
  let(:foo) { 100 }

  it 'matcher fails properly' do
    delay_with_promise 0 do
      1.should == 2
    end
  end

  it 'matcher succeeds' do
    delay_with_promise 0 do
      1.should == 1
    end
  end

  context 'non-assertion failure in promise' do
    it 'no args' do
      promise = PromiseV2.new
      delay 0 do
        promise.reject
      end
      promise
    end

    # We deliberately remove this feature, as this makes RSpec go bonkers...
    xit 'string arg' do
      promise = PromiseV2.new
      delay 0 do
        promise.reject 'string failure reason here'
      end
      promise
    end

    it 'exception arg' do
      delay_with_promise 0 do
        raise TypeError, 'typeerror driven failure reason here'
      end
    end
  end

  context 'skipped' do
    it 'via variable', skip: true do
      obj = [1, 2, 3, 4]

      delay_with_promise 0 do
        obj.should == [2, 2, 3, 4]
      end
    end

    xit 'via xit' do
      obj = [1, 2, 3, 4]

      delay_with_promise 0 do
        obj.should == [2, 2, 3, 4]
      end
    end

    it 'in example, inside promise' do
      delay_with_promise 0 do
        skip 'want to skip within'
      end
    end

    it 'in example, outside promise' do
      skip 'want to skip within'
      delay_with_promise 0 do
        1.should == 1
      end
    end
  end

  context 'pending' do
    it 'in example' do
      obj = [1, 2, 3, 4]

      delay_with_promise 0 do
        pending 'want to pend within'
        obj.should == [2, 2, 3, 4]
      end
    end

    it 'via variable', pending: 'the reason' do
      obj = [1, 2, 3, 4]

      delay_with_promise 0 do
        obj.should == [2, 2, 3, 4]
      end
    end
  end

  it "should make example fail properly before async block reached" do
    expect(:foo).to eq(:baz)

    delay_with_promise(0) do
      expect(nil).to eq 'we reached this assertion and we should not have'
    end
  end
end

describe 'async/sync mix' do
  it 'fails properly if a sync test is among async tests' do
    1.should == 2
  end

  it 'is an async test between 2 sync tests' do
    delay_with_promise 0 do
      1.should == 1
    end
  end

  it 'passes correctly if a sync test is among async tests' do
    1.should == 1
  end

  it "can finish running after a long delay and fail properly" do
    @test_in_progress = 'can finish running after a long delay and fail'
    obj = [1, 2, 3, 4]

    delay_with_promise 1 do
      obj.should == [2, 2, 3, 4]
      @test_in_progress = nil
    end
  end

  it "can finish running after a long delay and succeed" do
    obj = [1, 2, 3, 4]

    delay_with_promise 1 do
      obj.should == [1, 2, 3, 4]
    end
  end
end
