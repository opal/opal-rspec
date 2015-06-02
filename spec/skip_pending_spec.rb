describe 'skip/pending' do
  it 'in example, no promise' do
    skip 'want to skip within'
  end
  
  it 'in example without a promise' do
    obj = [1, 2, 3, 4]
    obj.should == [2, 2, 3, 4]
    pending 'want to pend within'
  end
end
