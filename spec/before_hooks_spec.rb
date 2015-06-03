describe 'hooks' do
  describe 'before' do
    context 'async' do
      let(:raise_before_error) { false }
      before do
        # self/instance variables will not work inside delay
        set_test_val = lambda {|v| @test_value = v}
        raise_err = raise_before_error
        delay_with_promise 0 do
          raise 'problem in before' if raise_err
          set_test_val[42]
        end
      end
    context 'both sync' do  
      subject { 42 }
      
      context 'context' do
        context 'success' do
          before :context do
            @@before_context_both_sync = 22
          end
        
          before do
            raise "@@before_context_both_sync should already be 22!" unless @@before_context_both_sync == 22
            @test_value = 42
          end
        
          it { is_expected.to eq @test_value }          
        end
        
        context 'fails properly' do
          before :context do
            raise 'it failed!'
            @@before_context_both_sync = 55
          end
        
          before do
            raise "before_context should have failed already!" if @@before_context_both_sync == 55
          end
        
          it { is_expected.to eq @test_value }
        end
      end
  
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
      
      context 'first before in chain triggers failure' do
        before do
          raise 'first before fails'
        end
        
        context 'inner context' do
          before do
            puts 'SHOULD NOT SEE THIS'
          end
          
          it { is_expected.to eq @test_value }
        end
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
