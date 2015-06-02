describe 'hooks' do
  describe 'after' do
    before :all do
      @@total = 0
    end
    
    after :all do
      expected = 10
      raise "Expected #{expected} after hits but got #{@@total}" unless @@total == expected
    end
    
    let(:raise_before_error) { false }
    before do
      raise 'before problem' if raise_before_error
    end
    
    let(:raise_after_error) { false }
    after do
      raise 'after problem' if raise_after_error
      @@total += 1      
    end
    
    context 'sync' do
      subject { 42 }            
      
      context 'before fails' do
        let(:raise_before_error) { true }
        
        it { is_expected.to eq 42 }
      end
      
      context 'match succeeds' do
        context 'sync match' do
          it { is_expected.to eq 42 }
        end
        
        it 'async match' do
          delay_with_promise 0 do
            expect(subject).to eq 42
          end
        end
      end
      
      context 'match fails' do
        context 'sync match' do
          it { is_expected.to eq 43 }
        end
        
        it 'async match' do
          delay_with_promise 0 do
            expect(subject).to eq 43
          end
        end
      end     
      
      context 'after fails' do
        let(:raise_after_error) { true }
        
        it { is_expected.to eq 42 }
      end
    end
    
    context 'async' do
      subject do
        delay_with_promise 0 do
          42
        end
      end            
      
      context 'before fails' do
        let(:raise_before_error) { true }
        
        it { is_expected.to eq 42 }
      end
      
      context 'match succeeds' do
        context 'sync match' do
          it { is_expected.to eq 42 }
        end
        
        it 'async match' do
          delay_with_promise 0 do
            expect(subject).to eq 42
          end
        end
      end
      
      context 'match fails' do
        context 'sync match' do
          it { is_expected.to eq 43 }
        end
        
        it 'async match' do
          delay_with_promise 0 do
            expect(subject).to eq 43
          end
        end
      end     
      
      context 'after fails' do
        let(:raise_after_error) { true }
        
        it { is_expected.to eq 42 }
      end
    end        
  end
end
