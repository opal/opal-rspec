describe 'subject' do
  context 'sync' do
    subject { 42 }
    
    context 'passes' do
      it { is_expected.to eq 42 }
    end
    
    context 'assertion fails properly' do
      it { is_expected.to eq 43 }
    end
    
    context 'fails properly during subject create' do
      subject do
        raise 'did not work'
      end
    
      it { is_expected.to eq 42 }
    end
  end
  
  context 'async' do
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
end
