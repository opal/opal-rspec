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
