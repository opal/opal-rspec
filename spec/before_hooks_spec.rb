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
      
      context 'with sync subject' do
        subject { 42 }

        context 'succeeds' do
          it { is_expected.to eq @test_value }
        end

        context 'before fails properly' do
          let(:raise_before_error) { true }
        
          # Won't run, but needs to be here to make test go
          it { is_expected.to eq @test_value }
        end

        context 'match fails properly' do
          it { is_expected.to_not eq @test_value }
        end
        
        context 'async match' do
          it 'succeeds' do
            delay_with_promise 0 do
              expect(subject).to eq @test_value
            end
          end
          
          it 'fails properly' do
            delay_with_promise 0 do
              expect(subject).to_not eq @test_value
            end
          end
        end
      end
      
      context 'with async subject' do
        let(:raise_before_subj_error) { false }
        
        subject do
          raise_err = raise_before_subj_error
          delay_with_promise 0 do
            raise 'problem in subject' if raise_err
            42
          end
        end

        context 'both succeed' do
          it { is_expected_to eq @test_value }
        end

        context 'both fail properly' do
          let(:raise_before_error) { true }
          let(:raise_before_subj_error) { true }
          
          # Won't run, but needs to be here to make test go
          it { is_expected_to eq @test_value }
        end

        context 'before succeeds, assertion fails properly' do
          it { is_expected_to_not eq @test_value }
        end

        context 'before fails properly' do
          let(:raise_before_error) { true }
          
          # Won't run, but needs to be here to make test go
          it { is_expected_to eq @test_value }
        end

        context 'before succeeds, subject fails properly' do
          let(:raise_before_subj_error) { true }
          
          # Won't run, but needs to be here to make test go
          it { is_expected_to eq @test_value }
        end        
        
        context 'async match' do
          it 'succeeds' do
            delay_with_promise 0 do
              expect(subject).to eq @test_value
            end
          end
          
          it 'fails properly' do
            delay_with_promise 0 do
              expect(subject).to_not eq @test_value
            end
          end
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
