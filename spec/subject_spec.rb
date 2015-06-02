describe 'subject' do    
  context 'sync' do
    context 'named' do
      subject(:named_subject) { [1, 2, 3] }

      it "should be the subject" do
        subject.should be_kind_of(Array)
      end

      it "should be the named subject" do
        subject.should eql(named_subject)
      end     
    end
    
    context 'unnamed' do
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
  end
  
  # context 'async' do
#     describe 'assertion' do
#       subject do
#         delay_with_promise 1 do
#           42
#         end
#       end
#
#       context 'passes' do
#         it { is_expected.to eq 42 }
#       end
#
#       context 'assertion fails properly' do
#         it { is_expected.to eq 43 }
#       end
#     end
#
#     context 'fails properly during subject create' do
#       subject do
#         delay_with_promise 1 do
#           raise 'did not work'
#         end
#       end
#
#       it { is_expected.to eq 42 }
#     end
#   end
end
