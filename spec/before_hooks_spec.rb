describe 'hooks' do
  describe 'before' do
    context 'async' do
      let(:raise_before_error) { false }
      before do
        promise = Promise.new
        # self/instance variables will not work inside delay
        set_test_val = lambda {|v| @test_value = v}
        raise_err = raise_before_error
        delay 1 do
          raise 'problem in before' if raise_err
          set_test_val[42]
          promise.resolve
        end
        promise
      end
      
      context 'with sync subject' do
        subject { 42 }

        context 'succeeds' do
          it { is_expected.to eq @test_value }
        end

        context 'before fails properly' do
          let(:raise_before_error) { true }
        
          it { is_expected.to eq @test_value }
        end

        context 'match fails properly' do
          it { is_expected.to_not eq @test_value }
        end
      end
      
      context 'with async subject' do
        subject do
          promise = Promise.new
          delay 1 do
            promise.resolve 42
          end
          promise
        end

        context 'both succeed' do
          pending 'write this'
        end

        context 'both fail properly' do
          let(:raise_before_error) { true }
          pending 'write this'
        end

        context 'before succeeds, assertion fails properly' do
          pending 'write this'
        end

        context 'before fails properly' do
          let(:raise_before_error) { true }
          pending 'write this'
        end

        context 'before succeeds, subject fails properly' do
          pending 'write this'
        end
      end
    end    
  
    context 'both sync' do  
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
end
