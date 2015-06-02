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
  it 'in example, no promise' do
    obj = [1, 2, 3, 4]
    obj.should == [2, 2, 3, 4]
    pending 'want to pend within'
  end
end
