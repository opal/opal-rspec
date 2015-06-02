describe 'hooks' do
  describe 'sync before' do  
    subject { 42 } 
  
    context 'succeeds' do
      before do
        @test_value = 42
      end
    
      it { is_expected.to eq @test_value }
    end
  
    context 'before fails properly' do
      before do
        raise 'something did not work right'
      end
    
      it { is_expected.to eq @test_value }
    end
  
    context 'match fails properly' do
      before do
        @test_value = 42
      end
    
      it { is_expected.to_not eq @test_value }
    end
  end  
end
