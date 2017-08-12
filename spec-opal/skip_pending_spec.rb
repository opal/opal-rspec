require 'spec_helper'

describe 'skip' do
  it 'in example, no promise' do
    skip 'want to skip within'
  end

  it 'no implementation provided'

  skip 'entire group' do
    it 'example 1' do
      1.should == 2
    end

    it 'example 2' do
      1.should == 3
    end
  end

  xit 'via xit' do
    1.should == 3
  end

  it 'via variable', skip: true do
    1.should == 3
  end
end

describe 'pending' do
  context 'in example' do
    context 'no promise' do
      it 'would fail otherwise' do
        pending 'want to pend within example'
        obj = [1, 2, 3, 4]
        obj.should == [2, 2, 3, 4]
      end

      it 'would not fail otherwise, thus fails properly' do
        pending 'want to pend within example'
        obj = [1, 2, 3, 4]
        obj.should == [1, 2, 3, 4]
      end
    end
  end
end
